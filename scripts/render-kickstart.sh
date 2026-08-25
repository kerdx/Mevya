#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MEVYA_ROOT=$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)
TEMPLATE="${MEVYA_ROOT}/kickstarts/mevya-live.ks.in"
PACKAGES="${MEVYA_ROOT}/packages/mevya-live.packages"
CONFIG_ROOT="${MEVYA_ROOT}/system_files"
OUTPUT="${1:-${MEVYA_ROOT}/kickstarts/mevya-live.ks}"

[[ -f "${TEMPLATE}" ]]
[[ -f "${PACKAGES}" ]]
[[ -d "${CONFIG_ROOT}" ]]

mkdir -p "$(dirname -- "${OUTPUT}")"

while IFS= read -r line || [[ -n "${line}" ]]; do
    line=${line%$'\r'}
    case "${line}" in
        __MEVYA_PACKAGES__)
            sed '/^[[:space:]]*#/d;/^[[:space:]]*$/d' "${PACKAGES}"
            ;;
        __MEVYA_CONFIG_POST__)
            while IFS= read -r -d '' file; do
                relative=${file#"${CONFIG_ROOT}"/}
                target=/${relative}
                directory=$(dirname -- "${target}")
                mode=$(stat -c '%a' "${file}")
                encoded=$(base64 -w0 "${file}")
                printf 'install -d -m 0755 %q\n' "${directory}"
                printf "printf '%%s' %q | base64 -d > %q\n" "${encoded}" "${target}"
                printf 'chmod %s %q\n' "${mode}" "${target}"
            done < <(find "${CONFIG_ROOT}" -type f -not -name .gitkeep -print0 | sort -z)
            ;;
        *)
            printf '%s\n' "${line}"
            ;;
    esac
done < "${TEMPLATE}" > "${OUTPUT}"

chmod 0644 "${OUTPUT}"
printf 'Generated %s\n' "${OUTPUT}"
