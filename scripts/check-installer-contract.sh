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
    "system_files/etc/greetd/config.toml"
    "system_files/etc/xdg/labwc/autostart"
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
network_firstboot="system_files/usr/local/sbin/mevya-firstboot-network"
depot_enable_hook="system_files/usr/local/libexec/mevya-enable-dank-software-depot.py"
depot_widget_hook="system_files/usr/local/libexec/mevya-add-dank-software-depot-widget.py"

require_text "$build_script" 'inst.profile=mevya' 'explicit Anaconda profile selection'
require_text "$build_script" 'inst.geoloc=provider_fedora_geoip' 'Fedora geolocation provider'
require_text "$profile" 'profile_id = mevya' 'Mevya Anaconda profile id'
require_text "$profile" 'base_profile = fedora' 'Fedora profile inheritance'
require_text "$profile" 'efi_dir = fedora' 'Fedora EFI directory'
require_text "$profile" 'default_on_boot = FIRST_WIRED_WITH_LINK' 'wired network default'
require_text "$profile" 'default_scheme = BTRFS' 'Btrfs default scheme'
require_text "$profile" 'btrfs_compression = zstd:1' 'Btrfs compression'
require_text "$profile" 'webui_web_engine = firefox' 'Firefox Anaconda WebUI engine'
require_text "system_files/etc/greetd/config.toml" 'command = "/usr/bin/dms-greeter --command labwc"' 'DMS greeter labwc compositor'
require_text "system_files/etc/xdg/labwc/autostart" 'systemctl --user --no-block start labwc-session.target' 'labwc systemd session target'

require_text "$installer" '/usr/bin/liveinst "$@"' 'official liveinst delegation'
require_text "$installer" 'status=$?' 'installer exit status capture'
if grep -Fq -- 'dms-greeter --command /usr/local/bin/mevya-session' "system_files/etc/greetd/config.toml"; then
    error "dms-greeter must receive the compositor id labwc, not the session wrapper path"
fi
if grep -Fq -- 'systemctl --user start graphical-session.target' "system_files/etc/xdg/labwc/autostart"; then
    error "labwc must activate labwc-session.target so graphical-session.target dependencies become usable"
fi
if grep -Eq 'inst\.(lang|singlelang)(=|[[:space:]])' "$build_script" "$installer"; then
    error "Build must not force a single Anaconda installer language"
fi
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

require_file "$network_firstboot" 'network firstboot script'
require_file "$depot_enable_hook" 'Depot enable hook'
require_file "$depot_widget_hook" 'Depot widget hook'
require_text "$network_firstboot" 'Live session detected; skipping Dank Software Depot' 'live Depot skip'
require_text "$network_firstboot" 'timeout 120s /usr/local/sbin/mevya-install-dank-software-depot' 'installed-system Depot retry'
require_text "$depot_enable_hook" 'running_from_live' 'live guard for Depot enable hook'
require_text "$depot_widget_hook" 'running_from_live' 'live guard for Depot widget hook'

if grep -Fq -- 'timeout 120s /usr/local/sbin/mevya-install-dank-software-depot' "$kickstart"; then
    error "Kickstart must not install Dank Software Depot during live image compose"
fi
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

for package in anaconda anaconda-live anaconda-webui python3-langtable glibc-all-langpacks xkeyboard-config firefox grub2-efi-x64 grub2-pc NetworkManager \
    python3-libdnf5 python3-gobject-base appstream-data ffmpegthumbnailer; do
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
