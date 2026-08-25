# Mevya TODO

## Profili installabili post-installazione

La ISO principale deve rimanere una base desktop completa ma essenziale. Gli
strumenti specializzati dovranno essere installabili dopo l'installazione,
senza aumentare il peso e la superficie di manutenzione della ISO base.

### Profilo sviluppatore

- aggiungere Podman, Distrobox e gli strumenti container correlati;
- valutare Buildah, Skopeo, `containers-common`, `conmon`, `crun`,
  `fuse-overlayfs` e `podman-compose` in base alle dipendenze Fedora disponibili;
- includere strumenti per sviluppo e diagnostica solo quando richiesti;
- integrare l'installazione nel Dank Software Depot o in un futuro gestore di
  profili Mevya;
- permettere rimozione e aggiornamento del profilo senza ricostruire la ISO.

### Altri profili da valutare

- Multimedia avanzato: strumenti di editing, registrazione e produzione;
- Hardware e diagnostica: `smartmontools`, `nvme-cli`, `lm_sensors`,
  `libinput-utils`, `libva-utils` e strumenti analoghi;
- Stampa e scansione: CUPS, SANE, `ipp-usb` e discovery Avahi;
- Virtualizzazione: strumenti Guest Additions, libvirt, QEMU/KVM e virt-manager;
- Mobile e dispositivi: supporto esteso MTP, Android, modem e periferiche;
- Gaming: layer compatibilità, strumenti controller e componenti opzionali.

## Regole per i profili

- la ISO base non deve includere Podman, Distrobox o tool diagnostici non
  necessari al funzionamento quotidiano;
- ogni profilo deve avere un manifest pacchetti separato e verificabile;
- i profili devono usare i repository Fedora/RPM Fusion/COPR già supportati,
  senza duplicare pacchetti nel manifest della ISO;
- l'installazione deve essere trasparente, aggiornabile e reversibile;
- le dipendenze devono essere calcolate dal gestore pacchetti, senza copiare
  manualmente interi gruppi di pacchetti;
- ogni profilo deve essere documentato e testato sia su hardware reale sia in
  VirtualBox quando pertinente.

## Pulizia già applicata alla ISO base

Sono stati rimossi dal manifest principale gli strumenti opzionali non usati
direttamente dal desktop: Podman, Distrobox, `wlrctl`, `nv-codec-headers`,
`powerstat`, `libinput-utils`, `libva-utils` e `swaybg`.