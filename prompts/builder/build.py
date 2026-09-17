#!/usr/bin/env python3
"""
Prompt Theme Builder
Reads colour palettes from colors.md and renders prompt engine templates
(Starship TOML, Oh My Posh JSON) following the canonical ANSI-to-prompt mapping.

Template naming convention:
  <engine>.<ext>.template       → default variant (for x theme)
  <engine>.<variant>.<ext>.template → named variant (for all other themes)
"""

import os
import re
import json
import sys

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REF_FILE = os.path.join(ROOT_DIR, 'colors.md')
TEMPLATES_DIR = os.path.join(ROOT_DIR, 'prompts', 'builder', 'templates')
BUILDER_DIR = os.path.join(ROOT_DIR, 'prompts', 'builder')
PROMPTS_DIR = os.path.join(ROOT_DIR, 'prompts')

# Output to test/ directory for review before copying to live theme dirs
TEST_DIR = os.path.join(BUILDER_DIR, 'test')

STARSHIP_TEST_DIR = os.path.join(TEST_DIR, 'starship')
OHMYPOSH_TEST_DIR = os.path.join(TEST_DIR, 'ohmyposh')

# Variant assignment: which variant template to use for which theme.
# Themes not listed here use the "combo" variant (or "default" if no combo template exists).
THEME_VARIANTS = {
    'x': 'default',
    'tokio': 'tokio',
}


def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))


def parse_palettes():
    with open(REF_FILE, 'r', encoding='utf-8') as f:
        content = f.read()

    pattern = re.compile(
        r'<h2[^>]*>([^<]+)</h2>\s*```json\s*\n(\{.*?\n)```',
        re.DOTALL
    )
    blocks = pattern.findall(content)

    themes = {}
    for name, json_text in blocks:
        name = name.strip().lower()
        try:
            colors = json.loads(json_text)
            themes[name] = colors
        except json.JSONDecodeError:
            print(f"Error parsing JSON for {name}")
    return themes


def expand_colors(base_colors):
    expanded = {}
    for key, val in base_colors.items():
        if isinstance(val, str) and val.startswith('#'):
            expanded[key] = val
            expanded[key + '_hex'] = val.lstrip('#')
            r, g, b = hex_to_rgb(val)
            expanded[key + '_r'] = str(r)
            expanded[key + '_g'] = str(g)
            expanded[key + '_b'] = str(b)
            expanded[key + '_rf'] = f"{r/255.0:.3f}"
            expanded[key + '_gf'] = f"{g/255.0:.3f}"
            expanded[key + '_bf'] = f"{b/255.0:.3f}"
        else:
            expanded[key] = val
    return expanded


def render_template(template_content, colors):
    rendered = template_content
    for key, val in colors.items():
        rendered = rendered.replace('{{ ' + key + ' }}', val)
    return rendered


def parse_template_name(template_name):
    """Parse template filename into (engine, variant, ext).
    Examples:
      starship.toml.template      -> ('starship', 'default', 'toml')
      starship.combo.toml.template -> ('starship', 'combo', 'toml')
    """
    base = template_name.replace('.template', '')
    parts = base.split('.')
    if len(parts) == 2:
        return parts[0], 'default', parts[1]
    elif len(parts) == 3:
        return parts[0], parts[1], parts[2]
    return parts[0], 'default', '.'.join(parts[1:])


def build_themes():
    themes = parse_palettes()
    print(f"Parsed {len(themes)} palettes from colors.md")

    if not os.path.exists(TEMPLATES_DIR):
        print(f"Templates directory not found: {TEMPLATES_DIR}")
        return

    template_files = [f for f in os.listdir(TEMPLATES_DIR) if f.endswith('.template')]
    if not template_files:
        print(f"No .template files found in {TEMPLATES_DIR}")
        return

    # Group templates by engine + ext
    engine_templates = {}
    for tf in template_files:
        engine, variant, ext = parse_template_name(tf)
        key = (engine, ext)
        if key not in engine_templates:
            engine_templates[key] = {}
        engine_templates[key][variant] = tf

    for (engine, ext), variants in sorted(engine_templates.items()):
        if engine == 'starship':
            out_dir = STARSHIP_TEST_DIR
        elif engine == 'ohmyposh':
            out_dir = OHMYPOSH_TEST_DIR
        else:
            out_dir = os.path.join(BUILDER_DIR, 'test', engine)

        os.makedirs(out_dir, exist_ok=True)

        for theme_name, base_colors in themes.items():
            # Determine which variant to use
            variant = THEME_VARIANTS.get(theme_name)
            if variant is None:
                variant = 'combo' if 'combo' in variants else 'default'

            template_file = variants.get(variant) or variants.get('default') or next(iter(variants.values()))

            with open(os.path.join(TEMPLATES_DIR, template_file), 'r', encoding='utf-8') as f:
                template_content = f.read()

            colors = expand_colors(base_colors)
            colors['theme_name'] = theme_name
            rendered = render_template(template_content, colors)

            output_file = os.path.join(out_dir, f'{theme_name}.{ext}')
            with open(output_file, 'w', encoding='utf-8') as out:
                out.write(rendered)
            print(f"  → {output_file} ({variant})")

        print(f"Built {len(themes)} {engine} themes in {out_dir}/")

    print("\nDone. Generated files are in builder/test/. Review them, then copy to the live directories:")
    print("  cp -r prompts/builder/test/starship/* prompts/starship/themes/")
    print("  cp -r prompts/builder/test/ohmyposh/* prompts/ohmyposh/themes/")


if __name__ == "__main__":
    build_themes()
