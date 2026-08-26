#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$BASH_SOURCE")" && pwd)
MEVYA_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$MEVYA_ROOT"

failures=0

error() {
    printf 'Installer contract error: %s\n' "$*" >&2
    failures=$((failures + 1))
}

require_file() {
    local file=$1
    local description=$2
    if [[ ! -f "$file" ]]; then
        error "$description is missing: $file"
    fi
}

require_text() {
    local file=$1
    local needle=$2
    local description=$3
    if ! grep -Fq -- "$needle" "$file"; then
        error "$description is missing in $file: $needle"
    fi
}

required_files=(
    "scripts/build-iso.sh"
    "scripts/render-kickstart.sh"
    "kickstarts/mevya-live.ks.in"
    "system_files/etc/anaconda/profile.d/mevya.conf"
    "system_files/usr/local/bin/mevya-installer"
    "system_files/usr/local/bin/mevya-installer-diagnostics"
    "system_files/usr/local/sbin/mevya-firstboot"
    "system_files/etc/polkit-1/rules.d/49-mevya-liveinst.rules"
)

for file in "${required_files[@]}"; do
    require_file "$file" "required installer file"
done

profile="system_files/etc/anaconda/profile.d/mevya.conf"
build_script="scripts/build-iso.sh"
kickstart="kickstarts/mevya-live.ks.in"
installer="system_files/usr/local/bin/mevya-installer"
diagnostics="system_files/usr/local/bin/mevya-installer-diagnostics"
firstboot="system_files/usr/local/sbin/mevya-firstboot"

require_text "$build_script" 'inst.profile=mevya' 'explicit Anaconda profile selection'
require_text "$build_script" 'inst.geoloc=provider_fedora_geoip' 'Fedora geolocation provider'
require_text "$profile" 'profile_id = mevya' 'Mevya Anaconda profile id'
require_text "$profile" 'base_profile = fedora' 'Fedora profile inheritance'
require_text "$profile" 'efi_dir = fedora' 'Fedora EFI directory'
require_text "$profile" 'default_on_boot = FIRST_WIRED_WITH_LINK' 'wired network default'
require_text "$profile" 'default_scheme = BTRFS' 'Btrfs default scheme'
require_text "$profile" 'btrfs_compression = zstd:1' 'Btrfs compression'

require_text "$installer" '/usr/bin/liveinst "$@"' 'official liveinst delegation'
require_text "$installer" 'status=$?' 'installer exit status capture'
require_text "$diagnostics" 'anaconda.log' 'Anaconda log collection'
require_text "$diagnostics" 'program.log' 'program log collection'
require_text "$diagnostics" 'ks-script' 'Kickstart log collection'
require_text "$diagnostics" 'journal.log' 'boot journal collection'
require_text "$firstboot" 'live_installer_polkit_rule=' 'live polkit cleanup'
require_text "$firstboot" 'live_installer_desktop=' 'live desktop cleanup'
require_text "$firstboot" 'live_installer_launcher=' 'live launcher cleanup'
require_text "$firstboot" 'live_installer_diagnostics=' 'diagnostics cleanup'
require_text "$firstboot" 'live_installer_diagnostics=' 'diagnostics cleanup'
require_text "$firstboot" 'if [ "${is_live}" -eq 0 ]; then' 'installed-system cleanup guard'

for repo in \
    fedora-updates \
    mevya-danklinux \
    mevya-dms \
    mevya-nautilus-terminal \
    rpmfusion-free \
    rpmfusion-free-updates \
    rpmfusion-nonfree \
    rpmfusion-nonfree-updates; do
    require_text "$kickstart" "repo --name=$repo" "required repository"
done

for package in anaconda anaconda-live firefox grub2-efi-x64 grub2-pc NetworkManager; do
    require_text "packages/mevya-live.packages" "$package" "required installer package"
done

render_dir=$(mktemp -d)
trap 'rm -rf "$render_dir"' EXIT
scripts/render-kickstart.sh "$render_dir/mevya-live.ks" >/dev/null
rendered="$render_dir/mevya-live.ks"

if grep -Eq '^(__MEVYA_PACKAGES__|__MEVYA_CONFIG_POST__)$' "$rendered"; then
    error "rendered Kickstart contains unresolved template markers"
fi
require_text "$rendered" '/usr/local/bin/mevya-installer-diagnostics' 'diagnostics path in rendered Kickstart'
require_text "$rendered" 'systemctl enable mevya-firstboot.service' 'firstboot service in rendered Kickstart'
require_text "$rendered" 'systemctl enable mevya-firstboot-network.timer' 'network firstboot timer in rendered Kickstart'

if grep -Fq -- 'inst.noverifyssl' "$kickstart"; then
    error "Kickstart must not disable TLS verification"
fi

if ((failures > 0)); then
    exit 1
fi

printf '%s\n' 'Installer contract validation passed.'
