#!/usr/bin/env python3
"""Validate the repository's generated themes, configuration files and docs.

The checks are intentionally dependency-light so they can run locally and in CI:
  * JSON, TOML and XML/plist assets are parsed.
  * Shell scripts are checked with ``bash -n``.
  * Relative links in Markdown files must resolve.
  * YAML is checked when PyYAML is available.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tomllib
from pathlib import Path
from urllib.parse import unquote, urlparse
from xml.etree import ElementTree

ROOT = Path(__file__).resolve().parents[1]
SKIP_DIRS = {".git", "builder/test", "__pycache__"}
JSON_SUFFIXES = {".json"}
TOML_SUFFIXES = {".toml"}
XML_SUFFIXES = {".xml", ".itermcolors", ".terminal", ".tmTheme"}
YAML_SUFFIXES = {".yaml", ".yml"}
SHELL_SUFFIXES = {".sh"}


def iter_files(suffixes: set[str]) -> list[Path]:
    files: list[Path] = []
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix not in suffixes:
            continue
        rel = path.relative_to(ROOT)
        if any(part in SKIP_DIRS for part in rel.parts):
            continue
        files.append(path)
    return sorted(files)


def check_json(path: Path) -> str | None:
    try:
        with path.open(encoding="utf-8") as f:
            json.load(f)
    except (OSError, json.JSONDecodeError) as exc:
        return f"{path.relative_to(ROOT)}: {exc}"
    return None


def check_toml(path: Path) -> str | None:
    try:
        with path.open("rb") as f:
            tomllib.load(f)
    except (OSError, tomllib.TOMLDecodeError) as exc:
        return f"{path.relative_to(ROOT)}: {exc}"
    return None


def check_xml(path: Path) -> str | None:
    try:
        ElementTree.parse(path)
    except (OSError, ElementTree.ParseError) as exc:
        return f"{path.relative_to(ROOT)}: {exc}"
    return None


def check_shell(path: Path) -> str | None:
    result = subprocess.run(
        ["bash", "-n", str(path)],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        detail = (result.stderr or result.stdout).strip()
        return f"{path.relative_to(ROOT)}: {detail}"
    return None


def check_yaml(path: Path) -> str | None:
    try:
        import yaml  # type: ignore[import-not-found]
    except ImportError:
        return None
    try:
        with path.open(encoding="utf-8") as f:
            yaml.safe_load(f)
    except (OSError, yaml.YAMLError) as exc:
        return f"{path.relative_to(ROOT)}: {exc}"
    return None


LINK_RE = re.compile(r"(?<!\!)\[[^\]]*\]\(([^)]+)\)")
HREF_RE = re.compile(r'href=["\']([^"\']+)["\']')


def check_markdown_links(path: Path) -> list[str]:
    issues: list[str] = []
    text = path.read_text(encoding="utf-8", errors="replace")
    targets = LINK_RE.findall(text) + HREF_RE.findall(text)
    for raw in targets:
        target = raw.strip()
        if target.startswith("<") and ">" in target:
            target = target[1 : target.index(">")]
        target = target.split(" ", 1)[0]
        target = unquote(target)
        parsed = urlparse(target)
        if parsed.scheme or target.startswith("#") or target.startswith("//"):
            continue
        if target.startswith("/"):
            # Root-relative links are host-relative on GitHub; skip them here.
            continue
        clean = target.split("#", 1)[0].split("?", 1)[0]
        if not clean:
            continue
        destination = (path.parent / clean).resolve()
        try:
            destination.relative_to(ROOT.resolve())
        except ValueError:
            continue
        if not destination.exists():
            issues.append(f"{path.relative_to(ROOT)}: broken link {target!r}")
    return issues


def main() -> int:
    errors: list[str] = []
    checked = 0

    for path in iter_files(JSON_SUFFIXES):
        checked += 1
        error = check_json(path)
        if error:
            errors.append(error)
    for path in iter_files(TOML_SUFFIXES):
        checked += 1
        error = check_toml(path)
        if error:
            errors.append(error)
    for path in iter_files(XML_SUFFIXES):
        checked += 1
        error = check_xml(path)
        if error:
            errors.append(error)
    for path in iter_files(SHELL_SUFFIXES):
        checked += 1
        error = check_shell(path)
        if error:
            errors.append(error)
    for path in iter_files(YAML_SUFFIXES):
        checked += 1
        error = check_yaml(path)
        if error:
            errors.append(error)

    markdown_files = iter_files({".md"})
    for path in markdown_files:
        checked += 1
        errors.extend(check_markdown_links(path))

    print(f"Validated {checked} files ({len(markdown_files)} Markdown).")
    if errors:
        print("\nValidation failed:", file=sys.stderr)
        for error in errors:
            print(f"  {error}", file=sys.stderr)
        return 1

    print("All checked files are valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
