# Multimedia baseline

Mevya 44 Classic includes the multimedia baseline from the existing Mevya image
and extends it with the codec and GStreamer packages that Nobara documents for
H.264, H.265, AV1, recording and playback workflows.

The baseline also includes VP8/VP9 (`libvpx`), Opus audio, Bluetooth aptX,
PackageKit GStreamer codec discovery and NVIDIA codec headers. `libdvdcss` is
kept out of the base image because its legal status varies by country.

The package list intentionally does not include browsers, OBS, Steam, Blender,
Kdenlive or other applications. It provides the libraries and hardware
acceleration layer; applications can be added later without changing the
base ISO design.

Some Nobara components are patched or maintained in Nobara repositories, such
as `mesa-freeworld`, their OBS build and their codec fixup tooling. They are not
copied blindly into Mevya: the first Mevya 44 Classic ISO uses Fedora/RPM Fusion
packages, and missing or conflicting packages will be validated before the
first real compose.
