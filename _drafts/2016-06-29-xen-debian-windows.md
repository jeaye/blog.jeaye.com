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

Origin EON17-SLX
32GB DDR4 RAM
Core i7-3940XM @ 3.00GHz
2x GeForce GTX 670MX (SLI)
Corsair Neutron 240GB SSD
1TB Generic HDD

https://wiki.debian.org/VGAPassthrough
