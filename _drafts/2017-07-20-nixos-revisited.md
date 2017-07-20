---
title: "NixOS: lasting impression"
tags: [linux, nixos, nix, review]
---

Nearly two years ago, I wrote about [my first impression of
NixOS](https://blog.jeaye.com/2015/11/24/nixos/), as I was using it in my
workstation. While I adored the concept of a declarative OS, it didn't quite fit
the workflow I had in mind for my laptop. The post was finished with me
considering NixOS for my VPS, but I didn't quite want to move away from
DigitalOcean, which has support for only a few distros. What follows details how
I've been running NixOS since, what it took, and what I've learned.

### Dealing with DigitalOcean
Ever since I started with DigitalOcean a few years ago, they've been joy to work
with, so I really didn't want to leave. Alas, they don't support many distros,
and certainly not custom ISOs. The first droplet I was administrating was
already going against the grain, running Arch using [a script which converts
Debian to Arch in place](https://github.com/gh2o/digitalocean-debian-to-arch).

*"What a neat idea,"* I thought, *"to trick DigitalOcean into thinking it's
running a supported distro."*. A couple weeks later,
[nixos-in-place](https://github.com/jeaye/nixos-in-place) was born; it remains
the most stable solution for converting any running GNU/Linux setup to NixOS in
place.

### 

* Complex services (postfix, dovecot, acme, http, radicale, f2b, etc)
* No side effects in activation scripts
* Building leiningen projects with Nix is a pain (and it's slow to download deps
  again and again)
* Prefer Scheme/Guix to Nix
* Guix's free software is more appealing
* Can't disable X without having to compile a ton of openjdk + more
* Services can't be overridden (spamassassin blocked until next release)
* User home management in /etc
* Ensuring directories exist with `.manage-directory`
* Some packages move too slowly, so I need to pull from unstable
* IRC channel is still super helpful
