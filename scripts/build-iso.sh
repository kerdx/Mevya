#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CLASSIC_ROOT=$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)
RELEASEVER=${RELEASEVER:-44}
ARCH=${ARCH:-x86_64}
OUTPUT_DIR=${OUTPUT_DIR:-"${CLASSIC_ROOT}/release"}
WORK_DIR=${WORK_DIR:-"${CLASSIC_ROOT}/.work"}

for command in livemedia-creator; do
    command -v "${command}" >/dev/null 2>&1 || {
        printf 'Missing build dependency: %s\n' "${command}" >&2
        exit 1
    }
done

"${SCRIPT_DIR}/render-kickstart.sh" "${WORK_DIR}/mevya-live.ks"
mkdir -p "${OUTPUT_DIR}"

printf '%s\n' \
    'The Kickstart is ready.' \
    'This script intentionally stops before invoking livemedia-creator.' \
    'Run it with BUILD=1 only after the package and VirtualBox smoke checks pass.'

if [[ "${BUILD:-0}" != 1 ]]; then
    exit 0
fi

livemedia-creator \
    --ks "${WORK_DIR}/mevya-live.ks" \
    --no-virt \
    --resultdir "${OUTPUT_DIR}" \
    --project Mevya \
    --make-iso \
    --volid MEVYA_CLASSIC \
    --iso-only \
    --iso-name "mevya-clasic-${RELEASEVER}-${ARCH}.iso" \
    --releasever "${RELEASEVER}" \
    --macboot
