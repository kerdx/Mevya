# Mevya 44

Mevya 44 è una variante sperimentale Fedora mutable. È separata dalla variante
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
| Workflow GitHub | Preparato, build manuale con artifact ISO Mevya 44 |
| Prima ISO reale | Build completata, ISO e checksum pubblicati come artifact |

## Cosa include

### Desktop

- labwc come compositor/window manager Wayland;
- due spazi di lavoro predefiniti;
- DankMaterialShell per pannello, launcher, notifiche, calendario e impostazioni;
- greetd e `dms-greeter` per il login;
- Ptyxis come terminale predefinito, con integrazione GTK4/libadwaita;
- profilo Ptyxis “Mevya Material” con JetBrains Mono, palette Material 3
  chiara/scura, bell disattivato e scrollback limitato;
- Qt6ct è il backend Qt6 della sessione e DMS può aggiornarne i colori tramite
  Matugen quando è attivo il theming delle applicazioni;
- GTK/libadwaita configurato con preferenza scura per mantenere Nautilus
  coerente con il tema del desktop;
- tema base `adw-gtk3-theme` incluso per permettere a DMS/Matugen di applicare
  la palette anche alle applicazioni GTK3;
- DMS configurato per sincronizzare modalità chiara/scura con GTK e Qt tramite
  il desktop portal, in entrambe le direzioni;
- decorazioni labwc disattivate sulle finestre frame di DMS per evitare una
  seconda barra del titolo e un secondo pulsante di chiusura;
- titlebar Material con controlli espliciti, angoli arrotondati e ombre più
  leggere per le finestre normali;
- l’updater di DMS usa il backend nativo per DNF/DNF5 e Flatpak, senza il
  comando `ujust` della variante immutabile;
- Flatpak usa il remote di sistema Flathub; l’eventuale remote Fedora viene
  rimosso durante la preparazione dell’immagine;
- Nautilus come file manager, con GVfs, SMB e MTP;
- associazioni XDG per cartelle e URI `file:` impostate su Nautilus;
- “Apri nel terminale” di Nautilus configurato tramite `nautilus-open-any-terminal`;
- `xdg-terminal-exec`, scorciatoia labwc e variabile `TERMINAL` puntano a Ptyxis;
- Kanshi e wlr-randr per monitor e docking;
- portali XDG per labwc, screenshot e condivisione schermo;
- livelli DMS espliciti per labwc: barra in `top`, popup, modali, OSD e
  notifiche in `overlay`;
- DMS usa `ext-workspace-v1` e due workspace globali labwc, con scorciatoie
  `Super+1/2` e `Super+Shift+1/2` coerenti tra shell e compositor;
- modalità tiling manuale e reversibile: `Super+frecce` per il 50/50,
  `Super+Shift+frecce` per spostare la finestra, `Super+U` per tornare
  flottante, `Super+Ctrl+1/2/3` per i thirds e `Super+Ctrl+4..7` per i
  quadranti;
- dialoghi e utility vengono centrati automaticamente; Firefox Picture-in-
  Picture resta sempre sopra le finestre normali;
- lock-before-suspend, timeout idle e integrazione `loginctl` sono gestiti da
  DMS, mentre GTK4 viene aggiornato subito dopo un cambio palette Matugen;
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

I tre COPR fondamentali vengono abilitati in modo bloccante durante il
post-install: se uno non è raggiungibile o non è coerente con la release, la
compose fallisce invece di produrre una ISO incompleta.

DNF5 usa un drop-in Mevya con 10 download paralleli, `fastestmirror`,
`defaultyes` e cache dei pacchetti persistente (`keepcache`).

Non viene copiato il modello uBlue/bootc e non vengono inclusi `uupd`,
`rpm-ostree` o `bootc` nella variante immutabile separata.

## Installer e branding

- Anaconda live è incluso tramite i pacchetti Fedora `anaconda`,
  `anaconda-install-env-deps` e `anaconda-live`;
- il Kickstart prepara una live session con labwc/DMS;
- la live usa italiano (`it_IT.UTF-8`) e tastiera italiana come impostazioni
  predefinite;
- Anaconda include tutti i locale disponibili tramite `glibc-all-langpacks`;
- la lingua scelta in Anaconda viene esportata da `/etc/locale.conf` nella
  sessione, così DMS, GTK, Qt e le applicazioni usano lo stesso locale;
- il layout tastiera e le opzioni XKB scelti in Anaconda vengono letti dalla
  configurazione installata e passati dinamicamente a labwc;
- il nome host predefinito dell’installazione è `mevya`, modificabile in
  Anaconda;
- la live avvia automaticamente labwc tramite greetd dentro
  `dbus-run-session`, attivando anche `graphical-session.target` per DMS;
- l’autologin è limitato alla live; il sistema installato usa normalmente il
  greeter, senza ereditare l’account tecnico o l’autologin della live;
- il primo avvio del sistema installato rimuove l’utente tecnico live `mevya`
  e lascia il login normale tramite greeter;
- la voce grafica “Installa Mevya” viene rimossa dal sistema installato e
  resta disponibile solo nella live;
- l’utente live può avviare `liveinst` senza una seconda richiesta di
  autenticazione, limitatamente al programma dell’installer;
- il launcher dell’installer riporta automaticamente il focus alla finestra
  Anaconda su Wayland;
- `/etc/os-release` viene brandizzato come Mevya 44;
- GRUB usa `GRUB_DISTRIBUTOR="Mevya 44"`;
- Plymouth mostra il branding Mevya 44;
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
- compose Mevya 44 completata su base Fedora 44 con risoluzione dipendenze verificata;
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

Il workflow `Build Mevya 44 ISO` usa un runner Ubuntu con un container
Fedora 44 privilegiato come base tecnica. All’interno del container:

1. installa Lorax, `lorax-lmc-novirt` e Pykickstart;
2. valida il Kickstart con `ksvalidator`;
3. esegue `livemedia-creator --no-virt`;
4. genera il checksum SHA256;
5. pubblica ISO e checksum come artifact GitHub per 14 giorni.

La run riuscita `32656329383` ha completato compose, checksum e upload. Il
workflow corregge anche i permessi degli output creati dal container prima del
checksum e usa `actions/upload-artifact` v7 con runtime Node 24.

Il workflow è manuale e non modifica la pipeline uBlue. Dopo commit e push si
avvia da `Actions > Build Mevya 44 ISO > Run workflow`.

## Prossimi passi

1. Scaricare ISO e checksum dall’artifact della run riuscita.
2. Testare boot live, labwc/DMS, Ptyxis, Nautilus e Anaconda in VirtualBox.
3. Verificare codec, audio, video, monitor/dock e profili energetici.
4. Solo dopo il test, rifinire OOBE, branding Mevya 44 e profili hardware.

Questa variante resta sperimentale finché la ISO non viene avviata e installata
con successo in VirtualBox.
