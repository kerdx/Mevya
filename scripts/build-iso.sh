#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MEVYA_ROOT=$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)
RELEASEVER=${RELEASEVER:-44}
ARCH=${ARCH:-x86_64}
OUTPUT_DIR=${OUTPUT_DIR:-"${MEVYA_ROOT}/release"}
WORK_DIR=${WORK_DIR:-"${MEVYA_ROOT}/.work"}

for command in livemedia-creator; do
    command -v "${command}" >/dev/null 2>&1 || {
        printf 'Missing build dependency: %s\n' "${command}" >&2
        exit 1
    }
done

"${SCRIPT_DIR}/render-kickstart.sh" "${WORK_DIR}/mevya-live.ks"

if [[ "${BUILD:-0}" != 1 ]]; then
    printf '%s\n' \
        'The Kickstart is ready.' \
        'This script intentionally stops before invoking livemedia-creator.' \
        'Run it with BUILD=1 only after the package and VirtualBox smoke checks pass.'
    exit 0
fi

# livemedia-creator requires --resultdir to be absent at startup.
# Create only its parent; Lorax creates and owns the result directory.
mkdir -p "$(dirname -- "${OUTPUT_DIR}")"

livemedia-creator \
    --ks "${WORK_DIR}/mevya-live.ks" \
    --no-virt \
    --resultdir "${OUTPUT_DIR}" \
    --project "Mevya ${RELEASEVER}" \
    --make-iso \
    --volid MEVYA_44 \
    --iso-only \
    --iso-name "mevya-${RELEASEVER}-${ARCH}.iso" \
    --releasever "${RELEASEVER}" \
    --macboot \
    --extra-boot-args "inst.profile=mevya inst.geoloc=provider_fedora_geoip inst.geoloc-use-with-ks"
