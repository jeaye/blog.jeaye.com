---
title: My experience with NixOS
tags: [linux, nixos, review]
---

NixOS is a novel Linux distribution started in 2003; it's built upon the [Nix
package manger](https://en.wikipedia.org/wiki/Nix_package_manager) which
provides a functional, declarative approach to package management. NixOS takes
the direction of Nix and continues further to allow control over the entire OS,
from the file system to various services like SSH and HTTP, using the same
declarative syntax. This means an entire NixOS setup, including all services,
packages installed, and even configurations, can be represented in
Nix configuration files and, potentially, stored some place like Github.

Similar to how software like
[PlayOnLinux](https://en.wikipedia.org/wiki/PlayOnLinux) works, where each
program installed has its own WINE context and is stored completely separate
from all other programs (for ideal stability), Nix takes a
completely revised approach to storing both binaries and libraries in the Linux
file system. In functional programming terms, the typical file system of
a Linux machine is global, mutable state. Everything lives in one place, either
`/usr` or `/usr/local` or similar. This means it's very difficult to, for
example, have several versions of the same library installed at once.

As a novel way of avoiding [dependency
hell](https://en.wikipedia.org/wiki/Dependency_hell), Nix stores all installed
packages, including system libraries, in `/nix/store/<hash>-package-version`
(example: `/nix/store/dpmvp969yhdqs7lm2r1a3gng7pyq6vy4-subversion-1.1.3`). Each
package's dependencies are defined explicitly and Nix uses symbolic links to
ensure that, when using a given package, all of its dependencies are made
available. More info is available in the [Nix
manual](http://nixos.org/nix/manual/).

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
