# Mevya 44

Mevya 44 è una distribuzione desktop mutabile basata su Fedora 44, con una
sessione Wayland leggera e coerente costruita su labwc e DankMaterialShell
(DMS). Include Anaconda per l’installazione, DNF5 e Flatpak con Flathub, oltre a
Nautilus, Ptyxis, gestione energetica, supporto multimedia e tiling manuale
reversibile.

## Stato

| Area | Stato |
| --- | --- |
| Desktop | labwc + DMS integrati, con tema Material per GTK e Qt |
| Installer | Anaconda live con lingua, tastiera e hostname configurabili |
| Branding | Mevya 44 su sistema, GRUB e Plymouth |
| Multimedia | Codec, GStreamer, PipeWire e accelerazione hardware inclusi |
| Hardware | Firmware, driver Mesa, moduli kernel extra e strumenti per periferiche |
| Aggiornamenti firmware | fwupd con supporto EFI per gli aggiornamenti UEFI |
| Build | Kickstart e workflow GitHub Actions pronti per la compose |

## Desktop

- labwc come compositor/window manager Wayland e DMS per pannello, launcher,
  notifiche, calendario e impostazioni;
- due spazi di lavoro globali, gestiti da DMS e labwc;
- greetd con `dms-greeter` per il login;
- Ptyxis come terminale predefinito, con profilo “Mevya Material”, JetBrains
  Mono, palette Material 3 chiara/scura, bell disattivato e scrollback limitato;
- Nautilus come file manager, con GVfs, SMB, MTP, associazioni XDG e “Apri nel
  terminale” configurato per Ptyxis;
- xdg-user-dirs crea le cartelle standard (Documenti, Scaricati e Immagini)
  usando la lingua selezionata;
- Qt6ct, GTK/libadwaita e `adw-gtk3-theme` configurati per seguire la palette
  DMS/Matugen e mantenere coerenti modalità chiara e scura;
- decorazioni labwc disattivate sulle finestre frame di DMS, titlebar Material
  per le finestre normali, popup e dialoghi centrati, e PiP di Firefox sempre
  sopra le finestre normali;
- Kanshi e wlr-randr per monitor e docking, portali XDG per screenshot e
  condivisione schermo, e livelli labwc dedicati a barra, popup, OSD e
  notifiche;
- aggiornamenti DMS tramite backend nativo DNF5 e Flatpak; remote di sistema
  Flatpak impostato su Flathub;
- gestione di lock, idle e sospensione tramite DMS/loginctl, con aggiornamento
  immediato del tema GTK dopo i cambi Matugen;
- font Noto, JetBrains Mono, Cascadia Code NF e Material Symbols; zram,
  `systemd-oomd`, `power-profiles-daemon` e preset labwc performance/power-saver;
- clipboard, fallback e log DMS, splash screen Plymouth e integrazione per
  l’uso in VirtualBox.

### Scorciatoie

- `Super+1/2`: passa al workspace;
- `Super+Shift+1/2`: sposta la finestra nel workspace;
- `Super+frecce`: affianca la finestra in modalità 50/50;
- `Super+Shift+frecce`: sposta la finestra tra le regioni;
- `Super+Ctrl+1/2/3`: regioni thirds;
- `Super+Ctrl+4..7`: quattro quadranti;
- `Super+U`: torna al comportamento flottante;
- `Super+Tab` / `Super+Shift+Tab`: cambia finestra con OSD labwc.

La modalità tiling è manuale e reversibile: labwc resta un ambiente flottante,
senza diventare un window manager tiling automatico.

## Multimedia

La ISO include la base di librerie e codec per riproduzione, registrazione e
accelerazione hardware: FFmpeg Fedora, `libavcodec-freeworld`, codec RPM
Fusion, GStreamer base/good/bad/ugly/libav, OpenH264, PipeWire, H.264, H.265,
x265, AV1, VP8/VP9, Opus, LAME, `fdk-aac-free`, libcamera, VA-API, Mesa,
driver Intel, header NVIDIA NVENC e `ffmpegthumbnailer`.

Sono inclusi anche WirePlumber, Bluetooth aptX e PackageKit GStreamer. Browser,
VLC, MPV, OBS, Steam, Blender e Kdenlive restano installabili dall’utente e
non fanno parte della base. `libdvdcss` è escluso per le diverse normative
nazionali.

## Audio e firmware

L'audio usa PipeWire e WirePlumber come server e session manager, con il bridge pipewire-alsa per le applicazioni ALSA. Sono inclusi i firmware audio SOF, Intel e Cirrus, oltre al firmware ALSA per hardware compatibile, così da coprire meglio i laptop moderni e le schede audio specialistiche.

## Supporto hardware

La base hardware segue il modello Fedora: kernel, moduli extra e firmware
Linux vengono accompagnati dalla pila Mesa completa per grafica DRI, Vulkan e
VDPAU. Sono inclusi firmware AMD per GPU e microcode CPU, firmware GPU Intel e
`fwupd-efi` per gli aggiornamenti firmware UEFI compatibili con fwupd.

Il manifest include inoltre:

- gestione di dischi rimovibili, batterie, profili energetici e dispositivi
  Thunderbolt tramite `udisks2`, `upower`, `power-profiles-daemon` e `bolt`;
- supporto e diagnostica per USB, PCI, rete, NVMe, SMART, webcam e dispositivi
  video tramite `usbutils`, `pciutils`, `ethtool`, `nvme-cli`, `smartmontools` e
  `v4l-utils`;
- stampa USB moderna con `ipp-usb`, scanner SANE, Bluetooth e sensori laptop;
- lettori d’impronte tramite `fprintd` e modem WWAN tramite `ModemManager`;
- supporto per ospiti VirtualBox tramite `virtualbox-guest-additions`.

I driver NVIDIA proprietari non sono incorporati nella ISO: l’immagine usa la
base Fedora con Nouveau/Mesa e può essere estesa in seguito con i pacchetti
RPM Fusion appropriati per il modello installato.

## Repository e aggiornamenti

Il Kickstart usa Fedora, RPM Fusion free/nonfree e i COPR necessari per DMS,
DankLinux e Nautilus Open Any Terminal. I COPR fondamentali sono abilitati in
modo bloccante: se non sono raggiungibili o coerenti con Fedora 44, la compose
fallisce invece di generare una ISO incompleta.

DNF5 è configurato con 10 download paralleli e `fastestmirror`; mantiene
le conferme esplicite e non conserva la cache RPM (`defaultyes=False`, `keepcache=False`). Flatpak usa il remote di sistema Flathub; il remote Fedora viene
rimosso durante la preparazione dell’immagine.

Il plugin Dank Software Depot viene incluso direttamente nel manifest senza
fork del progetto upstream. La sua integrazione usa il runtime Python/GObject
e libdnf5 richiesto dal plugin, insieme ai dati AppStream e al supporto per le
miniature video. Il progetto upstream resta separato e aggiornabile
indipendentemente dalla distribuzione.

## Installer e sistema installato

- Anaconda usa la geolocalizzazione Fedora per proporre lingua e fuso orario;
  se non disponibile, usa inglese (en_US.UTF-8) e tastiera US, sempre modificabili;
  sono disponibili tutti i locale tramite `glibc-all-langpacks`;
- lingua, layout tastiera, opzioni XKB e hostname scelti in Anaconda vengono
  propagati al sistema installato, a DMS, GTK, Qt e labwc;
- la live avvia automaticamente labwc/DMS tramite greetd e `dbus-run-session`;
- l’autologin è attivo solo nella live. Nel sistema installato viene applicato
  solo se selezionato dall’utente in Anaconda;
- l’utente tecnico live `mevya` viene rimosso al primo avvio del sistema
  installato; l’accesso normale passa dal greeter;
- l’opzione “Installa Mevya” resta nella live e viene rimossa dal sistema
  installato;
- dalla live `liveinst` può essere avviato senza una seconda richiesta di
  autenticazione; il launcher riporta il focus alla finestra Anaconda;
- hostname predefinito: `mevya`, modificabile durante l’installazione;
- `/etc/os-release`, GRUB e Plymouth riportano il branding Mevya 44;
- l'account tecnico live `mevya` è bloccato e non ha una password predefinita;
  viene usato solo per l'autologin della live.

## Struttura del progetto

- `packages/mevya-live.packages`: manifest dei pacchetti;
- `kickstarts/mevya-live.ks.in`: template Kickstart;
- `system_files/`: configurazioni della live e del sistema installato;
- `system_files/etc/dms/mevya-dms-environment`: ambiente DMS condiviso;
- `scripts/render-kickstart.sh`: genera il Kickstart completo;
- `scripts/validate-project.sh`: verifica script, configurazioni, manifest e
  Kickstart renderizzato;
- `scripts/build-iso.sh`: prepara o compone localmente la ISO;
- `lorax-custom/`: spazio per future personalizzazioni Lorax;
- `.github/workflows/build.yml`: workflow GitHub Actions della ISO.

## Controlli e build

La validazione controlla sintassi Bash, YAML, JSON e XML, Kickstart renderizzato,
sezioni `%packages`/`%post`, manifest, configurazioni e pacchetti esclusi. Esegue
`ksvalidator` quando disponibile; la CI mantiene il controllo Kickstart bloccante.
compose usa Fedora 44 e viene eseguita in un container Fedora privilegiato su
GitHub Actions; genera ISO e checksum come artifact.

Per generare e controllare il Kickstart:

```bash
./scripts/render-kickstart.sh
./scripts/validate-project.sh
```

La build locale richiede Fedora con Lorax:

```bash
BUILD=1 ./scripts/build-iso.sh
```

La ISO viene salvata in `release/`. Compose precedenti hanno già generato ISO, checksum e artifact; ogni modifica successiva va comunque ricostruita e verificata. La build GitHub Actions è manuale:
`Actions > Build Mevya 44 ISO > Run workflow`.

Mevya 44 resta sperimentale finché la ISO non viene verificata con boot live,
installazione, labwc/DMS, Anaconda, Nautilus, Ptyxis, audio/video, monitor e
VirtualBox.
