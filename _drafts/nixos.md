---
title: My experience with NixOS
tags: [linux, nixos, review]
---

good:

easy install of steam/skype/etc
  dep management

upgrade a kernel with 1 line change

keep it all on github

grub allows selecting previous

can install from linux

bad:

nix-shell
  can't change PS1?
  needed to build anything sane
  ldd errors still

guixsd
  more strict on free software
  less mature
  based on nix
  uses scheme/guile

YCM and color_coded
  need to access libraries
    lua boost sdl etc
  they're not available
  need to generate configs with nix
    not fucking portable

awful documentation

can't just build software
  need nix expressions
  not good for developing C++ apps
  vim plugins don't work

to where does it install?
  ~/.nix-profile
  /nix store

no startx
  need a DM
  default DM doesn't read .xinit
    is no longer active
