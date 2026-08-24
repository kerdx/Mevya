#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MEVYA_ROOT=$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)
cd "${MEVYA_ROOT}"

failures=0

error() {
    printf 'Validation error: %s\n' "$*" >&2
    failures=$((failures + 1))
}

required_files=(
    "packages/mevya-live.packages"
    "kickstarts/mevya-live.ks.in"
    "system_files/etc/xdg/labwc/rc.xml"
    "system_files/etc/dms/mevya-dms-environment"
    "system_files/etc/skel/.config/DankMaterialShell/settings.json"
    "system_files/etc/skel/.config/DankMaterialShell/clsettings.json"
)

for file in "${required_files[@]}"; do
    [[ -f "${file}" ]] || error "missing required file: ${file}"
done

while IFS= read -r -d '' file; do
    bash -n "${file}" || error "invalid shell syntax: ${file}"
done < <(
    find scripts system_files -type f \( \
        -path 'scripts/*.sh' -o \
        -path 'system_files/usr/local/bin/*' -o \
        -path 'system_files/usr/local/sbin/*' -o \
        -path 'system_files/etc/xdg/labwc/autostart' \
    \) -print0 | sort -z
)

python3 - "${MEVYA_ROOT}" <<'PY'
import json
import sys
import xml.etree.ElementTree as element_tree
from pathlib import Path

root = Path(sys.argv[1])
errors = []

for path in sorted((root / "system_files").rglob("*.json")):
    try:
        with path.open(encoding="utf-8") as stream:
            json.load(stream)
    except (OSError, ValueError) as exc:
        errors.append(f"invalid JSON: {path.relative_to(root)} ({exc})")

labwc_config = root / "system_files/etc/xdg/labwc/rc.xml"
try:
    element_tree.parse(labwc_config)
except (OSError, element_tree.ParseError) as exc:
    errors.append(f"invalid XML: {labwc_config.relative_to(root)} ({exc})")

if errors:
    for error in errors:
        print(f"Validation error: {error}", file=sys.stderr)
    raise SystemExit(1)
PY

mapfile -t packages < <(
    sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' \
        packages/mevya-live.packages
)

required_runtime_packages=(
    power-profiles-daemon
    zram-generator-defaults
    systemd-oomd-defaults
)
for required_package in "${required_runtime_packages[@]}"; do
    if ! printf '%s\n' "${packages[@]}" | grep -Fxq "${required_package}"; then
        error "missing resource-management package: ${required_package}"
    fi
done

declare -A seen_packages=()
duplicate_packages=()
for package in "${packages[@]}"; do
    if [[ -n "${seen_packages[${package}]:-}" ]]; then
        duplicate_packages+=("${package}")
    fi
    seen_packages["${package}"]=1
done

if ((${#duplicate_packages[@]} > 0)); then
    error "duplicate packages: ${duplicate_packages[*]}"
fi

render_dir=$(mktemp -d)
trap 'rm -rf "${render_dir}"' EXIT
scripts/render-kickstart.sh "${render_dir}/mevya-live.ks" >/dev/null

if grep -qE '^(__MEVYA_PACKAGES__|__MEVYA_CONFIG_POST__)$' "${render_dir}/mevya-live.ks"; then
    error "rendered Kickstart still contains an unresolved template marker"
fi

for service in power-profiles-daemon.service systemd-oomd.service; do
    if ! grep -q "systemctl enable ${service}" "${render_dir}/mevya-live.ks"; then
        error "resource-management service is not enabled in Kickstart: ${service}"
    fi
done

if ((failures > 0)); then
    exit 1
fi

printf '%s\n' 'Project validation passed.'