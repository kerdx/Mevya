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
    plugin_settings = json.loads(plugin_settings_path.read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError):
    raise SystemExit(0)

plugin_state = plugin_settings.setdefault("dankSoftwareDepot", {})
if plugin_state.get("widgetDefaultApplied", False):
    raise SystemExit(0)

widgets = settings.setdefault("dankBarRightWidgets", [])
widget_ids = [item if isinstance(item, str) else item.get("id") for item in widgets]
if "dankSoftwareDepot" not in widget_ids:
    widgets.append("dankSoftwareDepot")

plugin_state["widgetDefaultApplied"] = True
settings_path.write_text(json.dumps(settings, indent=2) + "\n", encoding="utf-8")
plugin_settings_path.write_text(json.dumps(plugin_settings, indent=2) + "\n", encoding="utf-8")
