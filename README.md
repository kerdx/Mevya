# Mevya Classic

Variante sperimentale Fedora mutable di Mevya. È separata dalla variante
immutabile uBlue/bootc nella radice del repository e usa DNF per gli
aggiornamenti del sistema.

## Stato attuale

| Area | Stato |
| --- | --- |
| Configurazione labwc + DMS | Preparata e copiata dalla variante principale |
| Ptyxis + Nautilus | Inclusi e configurati |
| Multimedia e codec | Risoluzione pacchetti verificata nella compose |
| Kickstart live ISO | Preparato e renderizzato staticamente |
| Installer | Anaconda live di Fedora |
| GRUB/Plymouth | Branding Mevya configurato |
| Workflow GitHub | Preparato, build manuale con artifact ISO |
| Prima ISO reale | Build completata, ISO e checksum pubblicati come artifact |

## Cosa include

### Desktop

- labwc come compositor/window manager Wayland;
- DankMaterialShell per pannello, launcher, notifiche, calendario e impostazioni;
- greetd e `dms-greeter` per il login;
- Ptyxis come terminale predefinito, con integrazione GTK4/libadwaita;
- Nautilus come file manager, con GVfs, SMB e MTP;
- “Apri nel terminale” di Nautilus configurato tramite `nautilus-open-any-terminal`;
- `xdg-terminal-exec`, scorciatoia labwc e variabile `TERMINAL` puntano a Ptyxis;
- Kanshi, wlr-randr e wdisplays per monitor e docking;
- portali XDG per labwc, screenshot e condivisione schermo;
- font Material Symbols, Noto, JetBrains Mono e Cascadia Code NF;
- preset labwc performance e power-saver;
- temi Matugen per labwc e palette desktop coerente;
- clipboard DMS, fallback DMS e log della sessione grafica;
- Plymouth con splash screen Mevya.

### Multimedia

La baseline contiene 127 pacchetti tra desktop, librerie, plugin, boot e
supporto hardware:

- FFmpeg Fedora, `libavcodec-freeworld` e codec RPM Fusion compatibili con Anaconda;
- GStreamer base, good, bad, ugly, libav, OpenH264 e PipeWire;
- H.264, H.265, x265, AV1, VP8/VP9 e Opus;
- LAME e `fdk-aac-free` per l’audio;
- PipeWire, WirePlumber e Bluetooth aptX;
- libcamera e integrazione GStreamer per videocamere;
- VA-API, Mesa VA-API/VDPAU e driver Intel;
- header NVIDIA NVENC per l’accelerazione video;
- `ffmpegthumbnailer` per le anteprime video in Nautilus;
- PackageKit GStreamer per il rilevamento dei codec.

Non sono inclusi browser, VLC, MPV, OBS, Steam, Blender, Kdenlive o altre
applicazioni multimediali: l’immagine fornisce la base di librerie, codec e
accelerazione, lasciando le applicazioni all’utente.

`libdvdcss` è escluso dalla base perché la sua situazione legale varia in base
al Paese.

## Repository utilizzati

Il Kickstart abilita Fedora, RPM Fusion free/nonfree e i repository necessari
per i pacchetti selezionati:

- COPR DankLinux e DankMaterialShell;
- COPR Nautilus Open Any Terminal;
- RPM Fusion free e nonfree per codec e driver multimediali.

Non viene copiato il modello uBlue/bootc e non vengono inclusi `uupd`,
`rpm-ostree` o `bootc` nella variante Classic.

## Installer e branding

- Anaconda live è incluso tramite i pacchetti Fedora `anaconda`,
  `anaconda-install-env-deps` e `anaconda-live`;
- il Kickstart prepara una live session con labwc/DMS;
- Anaconda include tutti i locale disponibili tramite `glibc-all-langpacks`;
- il nome host predefinito dell’installazione è `mevya`, modificabile in
  Anaconda;
- la sessione Mevya avvia automaticamente labwc tramite greetd dentro
  `dbus-run-session`, attivando anche `graphical-session.target` per DMS;
- il primo avvio del sistema installato rimuove l’utente tecnico live `mevya`
  e trasferisce l’autologin all’utente creato in Anaconda;
- l’utente live può avviare `liveinst` senza una seconda richiesta di
  autenticazione, limitatamente al programma dell’installer;
- il launcher dell’installer riporta automaticamente il focus alla finestra
  Anaconda su Wayland;
- `/etc/os-release` viene brandizzato come Mevya Linux / Mevya Classic;
- GRUB usa `GRUB_DISTRIBUTOR="Mevya"`;
- Plymouth usa il tema Mevya;
- i servizi principali vengono abilitati nel sistema live e installato.

Durante lo sviluppo l’utente live è `mevya` con password temporanea `mevya`.
Questo valore deve essere rimosso o modificato prima di una distribuzione
pubblica.

## Struttura

- `packages/mevya-live.packages`: manifest dei pacchetti della ISO;
- `kickstarts/mevya-live.ks.in`: template Kickstart;
- `system_files/`: configurazioni installate nella live e nel sistema finale;
- `scripts/render-kickstart.sh`: genera il Kickstart completo;
- `scripts/build-iso.sh`: prepara o compone localmente la ISO;
- `lorax-custom/`: spazio per future personalizzazioni Lorax;
- `.github/workflows/build.yml`: workflow GitHub Actions della ISO.

## Controlli già eseguiti

- sintassi Bash degli script verificata;
- sintassi YAML del workflow verificata;
- Kickstart renderizzato correttamente;
- sezioni `%packages` e `%post` presenti;
- payload delle configurazioni convertibile e installabile;
- nessun browser o applicazione esclusa nel manifest;
- codec aggiunti e verificati nel manifest;
- compose Fedora 44 completata con risoluzione dipendenze verificata;
- ISO, checksum e artifact GitHub generati correttamente;
- `git diff --check` superato.

Sul sistema locale non sono installati `livemedia-creator`, `mock` e
`ksvalidator`; la compose riuscita è stata eseguita in GitHub Actions.

## Build locale

Per generare solo il Kickstart:

```bash
./scripts/render-kickstart.sh
```

La compose locale richiede un ambiente Fedora con Lorax:

```bash
BUILD=1 ./scripts/build-iso.sh
```

Lo script salva la ISO in `release/`.

## Build GitHub Actions

Il workflow `Build Mevya Classic ISO` usa un runner Ubuntu con un container
Fedora 44 privilegiato. All’interno del container:

1. installa Lorax, `lorax-lmc-novirt` e Pykickstart;
2. valida il Kickstart con `ksvalidator`;
3. esegue `livemedia-creator --no-virt`;
4. genera il checksum SHA256;
5. pubblica ISO e checksum come artifact GitHub per 14 giorni.

La run riuscita `32656329383` ha completato compose, checksum e upload. Il
workflow corregge anche i permessi degli output creati dal container prima del
checksum e usa `actions/upload-artifact` v7 con runtime Node 24.

Il workflow è manuale e non modifica la pipeline uBlue. Dopo commit e push si
avvia da `Actions > Build Mevya Classic ISO > Run workflow`.

## Prossimi passi

1. Scaricare ISO e checksum dall’artifact della run riuscita.
2. Testare boot live, labwc/DMS, Ptyxis, Nautilus e Anaconda in VirtualBox.
3. Verificare codec, audio, video, monitor/dock e profili energetici.
4. Solo dopo il test, rifinire OOBE, branding Fedora/Mevya e profili hardware.

Questa variante resta sperimentale finché la ISO non viene avviata e installata
con successo in VirtualBox.
