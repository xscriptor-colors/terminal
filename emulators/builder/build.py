#!/usr/bin/env python3
"""Build the terminal theme catalog from colors.md.

Usage:
    python3 emulators/builder/build.py            # render into builder/test
    python3 emulators/builder/build.py --write    # update the live themes
    python3 emulators/builder/build.py --check    # fail if live themes drift
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sys

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REF_FILE = os.path.join(ROOT_DIR, "colors.md")
EMULATORS_DIR = os.path.join(ROOT_DIR, "emulators")
TEMPLATES_DIR = os.path.join(EMULATORS_DIR, "builder", "templates")
TEST_DIR = os.path.join(EMULATORS_DIR, "builder", "test")
DCONF_DIR = os.path.join(EMULATORS_DIR, "gnome-terminal", "dconf")
DCONF_TEST_DIR = os.path.join(TEST_DIR, "gnome-terminal-dconf")
DCONF_TEMPLATE = os.path.join(TEMPLATES_DIR, "gnome-terminal.dconf.template")
GNOME_INSTALLER = os.path.join(EMULATORS_DIR, "gnome-terminal", "install.sh")

# Template directory names are filesystem-friendly; live directories follow
# the emulator names used by the installers.
GENERATED_DIR_ALIASES = {"terminal.app": "terminal-app"}


def hex_to_rgb(hex_str: str) -> tuple[int, int, int]:
    hex_str = hex_str.lstrip("#")
    return tuple(int(hex_str[i : i + 2], 16) for i in (0, 2, 4))


def parse_colors() -> dict[str, dict[str, str]]:
    with open(REF_FILE, "r", encoding="utf-8") as f:
        content = f.read()

    pattern = re.compile(r"<h2[^>]*>([^<]+)</h2>\s*```json\s*({[^}]+})\s*```")
    blocks = pattern.findall(content)

    themes: dict[str, dict[str, str]] = {}
    for name, json_text in blocks:
        name = name.strip().lower()
        try:
            themes[name] = json.loads(json_text)
        except json.JSONDecodeError:
            print(f"Error parseando JSON de {name}")
    return themes


def expand_colors(base_colors: dict[str, str]) -> dict[str, str]:
    expanded: dict[str, str] = {}
    for key, val in base_colors.items():
        if val.startswith("#"):
            expanded[key] = val
            expanded[key + "_hex"] = val.lstrip("#")

            r, g, b = hex_to_rgb(val)
            expanded[key + "_r"] = str(r)
            expanded[key + "_g"] = str(g)
            expanded[key + "_b"] = str(b)

            expanded[key + "_rf"] = f"{r / 255.0:.3f}"
            expanded[key + "_gf"] = f"{g / 255.0:.3f}"
            expanded[key + "_bf"] = f"{b / 255.0:.3f}"
        else:
            expanded[key] = val
    return expanded


def render_template(template_content: str, values: dict[str, str]) -> str:
    rendered = template_content
    for key, val in values.items():
        rendered = rendered.replace(f"{{{{ {key} }}}}", val)
    return rendered


def build_themes(themes: dict[str, dict[str, str]]) -> None:
    if not os.path.exists(TEMPLATES_DIR):
        raise SystemExit(f"No existe el directorio de plantillas: {TEMPLATES_DIR}")

    templates = sorted(
        f
        for f in os.listdir(TEMPLATES_DIR)
        if f.endswith(".template") and f != "gnome-terminal.dconf.template"
    )
    if not templates:
        raise SystemExit(f"No hay archivos .template en {TEMPLATES_DIR}")

    for template_name in templates:
        with open(os.path.join(TEMPLATES_DIR, template_name), "r", encoding="utf-8") as f:
            template_content = f.read()

        terminal_name = template_name.split(".")[0]
        ext = template_name.replace(f"{terminal_name}.", "", 1).replace(".template", "")

        term_test_dir = os.path.join(TEST_DIR, terminal_name)
        os.makedirs(term_test_dir, exist_ok=True)

        for theme_name, base_colors in themes.items():
            values = expand_colors(base_colors)
            values["theme_name_plain"] = theme_name
            rendered = render_template(template_content, values)

            output_file = os.path.join(term_test_dir, f"{theme_name}.{ext}")
            with open(output_file, "w", encoding="utf-8") as out:
                out.write(rendered)

        print(f"Construidos {len(themes)} temas para {terminal_name} en builder/test/{terminal_name}/")


def gnome_uuids() -> dict[str, str]:
    """Read the profile UUIDs from the GNOME installer (single source of truth)."""
    with open(GNOME_INSTALLER, "r", encoding="utf-8") as f:
        text = f.read()
    return {
        name.lower(): uuid
        for name, uuid in re.findall(r'^UUID_([A-Z]+)="([^"]+)"', text, re.MULTILINE)
    }


def build_dconf(themes: dict[str, dict[str, str]]) -> None:
    with open(DCONF_TEMPLATE, "r", encoding="utf-8") as f:
        template_content = f.read()

    uuids = gnome_uuids()
    os.makedirs(DCONF_TEST_DIR, exist_ok=True)

    for theme_name, base_colors in themes.items():
        uuid = uuids.get(theme_name)
        if not uuid:
            print(f"Warning: no UUID for theme {theme_name}; skipping dconf profile")
            continue

        values = expand_colors(base_colors)
        values["theme_name"] = theme_name
        values["uuid"] = uuid
        rendered = render_template(template_content, values)

        output_file = os.path.join(DCONF_TEST_DIR, f"{theme_name}.dconf")
        with open(output_file, "w", encoding="utf-8") as out:
            out.write(rendered)

    print(f"Construidos {len(themes)} perfiles dconf en builder/test/gnome-terminal-dconf/")


def tree_differences(expected_dir: str, actual_dir: str) -> list[str]:
    """Return a list of missing, extra or different files between two trees."""
    if not os.path.isdir(actual_dir):
        return [f"missing generated directory: {actual_dir}"]

    expected: dict[str, bytes] = {}
    actual: dict[str, bytes] = {}

    for base, store in ((expected_dir, expected), (actual_dir, actual)):
        for root, _dirs, files in os.walk(base):
            for filename in files:
                path = os.path.join(root, filename)
                rel = os.path.relpath(path, base)
                with open(path, "rb") as f:
                    store[rel] = f.read()

    messages: list[str] = []
    for rel in sorted(expected.keys() - actual.keys()):
        messages.append(f"missing: {rel}")
    for rel in sorted(actual.keys() - expected.keys()):
        messages.append(f"unexpected: {rel}")
    for rel in sorted(expected.keys() & actual.keys()):
        if expected[rel] != actual[rel]:
            messages.append(f"different: {rel}")
    return messages


def check_outputs() -> list[str]:
    issues: list[str] = []

    for name in sorted(os.listdir(EMULATORS_DIR)):
        if name == "builder":
            continue
        live = os.path.join(EMULATORS_DIR, name, "themes")
        generated_name = GENERATED_DIR_ALIASES.get(name, name)
        generated = os.path.join(TEST_DIR, generated_name)
        if not os.path.isdir(live):
            continue
        for message in tree_differences(generated, live):
            issues.append(f"{name}: {message}")

    for message in tree_differences(DCONF_TEST_DIR, DCONF_DIR):
        issues.append(f"gnome-terminal/dconf: {message}")

    return issues


def write_outputs() -> None:
    for name in sorted(os.listdir(EMULATORS_DIR)):
        if name == "builder":
            continue
        generated_name = GENERATED_DIR_ALIASES.get(name, name)
        generated = os.path.join(TEST_DIR, generated_name)
        live = os.path.join(EMULATORS_DIR, name, "themes")
        if not os.path.isdir(generated) or not os.path.isdir(live):
            continue
        shutil.rmtree(live)
        shutil.copytree(generated, live)
        print(f"Updated emulators/{name}/themes")

    shutil.rmtree(DCONF_DIR)
    shutil.copytree(DCONF_TEST_DIR, DCONF_DIR)
    print("Updated emulators/gnome-terminal/dconf")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--write",
        action="store_true",
        help="copy the generated themes into the live emulator directories",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="fail if the committed themes differ from the generated output",
    )
    args = parser.parse_args()

    os.makedirs(TEST_DIR, exist_ok=True)

    themes = parse_colors()
    print(f"Extraídos {len(themes)} temas desde colors.md")
    build_themes(themes)
    build_dconf(themes)

    if args.write:
        write_outputs()

    if args.check:
        issues = check_outputs()
        if issues:
            print("\nGenerated themes are out of sync:", file=sys.stderr)
            for issue in issues:
                print(f"  {issue}", file=sys.stderr)
            return 1
        print("All generated themes are in sync.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
