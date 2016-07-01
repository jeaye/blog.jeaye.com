---
title: Running GNU/Linux and Windows simultaneously (no VM)
tags: [linux, windows, xen, tutorial, vm]
---

For my wife's latest setup, I explored the Xen hypervisor and aimed to provide
her with a GNU/Linux host machine which could also run Windows 7
simultaneously, with each OS having its own dedicated GPU and display. Below, I
detail the steps I took, from start to finish.

### Installing Debian stable
[Debian](https://www.debian.org/) sits in a middle ground between my wife's
desire for avoiding the command line and my desire for a distro which respects
privacy and embraces free software. This setup isn't limited or specific to
Debian, however. The latest Debian (8.5.0 at the time of writing) AMD64 ISOs
are available, via torrent,
[here](http://cdimage.debian.org/debian-cd/current-live/amd64/bt-hybrid/).

The installation of Debian is [nicely documented](https://www.debian.org/releases/stable/amd64/), so I'll only point out notable changes in my setup and otherwise assume a normal installation.

#### Setting up the disk
During the disk partitioning step of the installation, I enabled full disk
encryption using LVM. This isn't needed for the Xen setup, but it's recommended
for the protection of your data.

I also opted to have `/home` on its own partition, since that allows for easier
changing of `/` while keeping users exactly as they were.

#### Choosing a desktop environment
As with most aspects in the GNU/Linux world, there's a good deal of
fragmentation with desktop environments. As my wife doesn't want anything
special, I went with GNOME. KDE, XFCE, and GNOME are all fine choices; for
those who like Unity, there have been [privacy
concerns](https://en.wikipedia.org/wiki/Unity_(user_interface)#Criticism) worth
noting.

### Installing nVidia drivers
I know my current hardware, so finding the right driver for it isn't an issue. If you're not sure, however, you can use the `nvidia-detect` tool:

```bash
aptitude update
aptitude install nvidia-detect
nvidia-detect
```

**NOTE:** You'll need to add `contrib non-free` to each source in your `/etc/apt/sources.list` (you likely also want to comment out the `cdrom` entry) before issuing these commands.

I issued the following, to get the nVidia ball rolling. Depending on your card series, you may not need this legazy version and `nvidia-driver` may work fine for you.

```bash
aptitude update
aptitude install linux-headers-$(uname -r | sed 's,[^-]*-[^-]*-,,') nvidia-legacy-304xx-kernel-dkms xserver-xorg-video-nvidia-legacy-304xx nvidia-support nvidia-xconfig nvidia-settings
```

The `Conflicting nouveau kernel module loaded` warnings are expected. I
generated the new Xorg config, then rebooted the system to leave the nouveau
drive behind.

```bash
nvidia-xconfig
reboot
```

Once the system comes back up, you can verify that your nVidia drivers are
operational.

```bash
nvidia-settings
```

### Installing QEMU
```bash
aptitude install qemu-kvm
```

Origin EON17-SLX
32GB DDR4 RAM
Core i7-3940XM @ 3.00GHz
2x GeForce GTX 670MX (SLI)
Corsair Neutron 240GB SSD
1TB Generic HDD

https://wiki.debian.org/VGAPassthrough
