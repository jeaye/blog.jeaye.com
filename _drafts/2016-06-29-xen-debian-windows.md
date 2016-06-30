---
title: Running GNU/Linux and Windows simultaneously (no VM)
tags: [linux, windows, xen, tutorial, vm]
---

For my wife's latest setup, I explored the Xen hypervisor and aimed to provide her with a GNU/Linux host machine which could also run Windows 7 simultaneously, with each OS having its own dedicated GPU and display. Below, I detail the steps I took, from start to finish.

### Installing Debian stable
Debian sits in a middle ground between my wife's desire for avoiding the command line and my desire for a distro which respects privacy and embraces free software. This setup isn't limited or specific to Debian, however. The latest Debian (8.5.0 at the time of writing) AMD64 ISOs are available, via torrent, [here](http://cdimage.debian.org/debian-cd/current-live/amd64/bt-hybrid/).

Origin EON17-SLX
32GB DDR4 RAM
Core i7-3940XM @ 3.00GHz
2x GeForce GTX 670MX (SLI)
Corsair Neutron 240GB SSD
1TB Generic HDD
