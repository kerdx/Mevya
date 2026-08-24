#!/usr/bin/env python3

import json
import os
from pathlib import Path


config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
dms_dir = config_home / "DankMaterialShell"
settings_path = dms_dir / "settings.json"
plugin_settings_path = dms_dir / "plugin_settings.json"

if not settings_path.is_file():
    raise SystemExit(0)

try:
    settings = json.loads(settings_path.read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError):
    raise SystemExit(0)

try:
    plugin_settings = json.loads(plugin_settings_path.read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError):
    plugin_settings = {}

plugin_state = plugin_settings.setdefault("dankSoftwareDepot", {})
if "enabled" not in plugin_state:
    plugin_state["enabled"] = True

# Apply the Mevya default once. A later user choice to remove the widget is
# preserved because the marker prevents this hook from re-adding it.
if not plugin_state.get("mevyaDefaultApplied", False):
    widgets = settings.setdefault("dankBarRightWidgets", [])
    widget_ids = [item if isinstance(item, str) else item.get("id") for item in widgets]
    if "dankSoftwareDepot" not in widget_ids:
        widgets.append("dankSoftwareDepot")
    plugin_state["mevyaDefaultApplied"] = True
    settings_path.write_text(json.dumps(settings, indent=2) + "\n", encoding="utf-8")

dms_dir.mkdir(parents=True, exist_ok=True)
plugin_settings_path.write_text(json.dumps(plugin_settings, indent=2) + "\n", encoding="utf-8")
