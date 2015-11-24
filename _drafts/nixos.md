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

### Why bother?
At this point, it may not be clear why NixOS is worth exploring. To anyone who
has used [Chef](https://en.wikipedia.org/wiki/Chef_%28software%29), or similar
software, to describe the construction of machines, especially for replication in
clusters (using, say,
[vagrant](https://en.wikipedia.org/wiki/Vagrant_%28software%29)), NixOS provides
even more control over the exact state of the machine. Furthermore, it doesn't
rely on wrangling existing distros (like Ubuntu), though this can be considered
a drawback. The biggest win is, since the entire system is controlled by Nix
files, and every bit of configuration and every package is described explicitly,
with all of its dependencies and environment, you can turn any NixOS machine
into something complete different instantly and without rebooting. Let's get to
some examples.

[My Nix files](https://github.com/jeaye/nix-files) describe the setup I was
building, which is my "desktop" workstation where I do primarily C++ and Clojure
development. I use Vim, watch movies with mplayer, listen to music with cmus,
etc; all of this is described within these configuration files. The nice thing
about declarative configuration is that you describe *how the system should look
when it's ready* not *how it should get there*.


#### Describing a NixOS system
As I said before, if you're doing it right, everything you need is in the form
of Nix files. We can start with [describing
GRUB](https://github.com/jeaye/nix-files/blob/master/grub.nix), instead of using
the typical grub commands and mutating `/etc/grub.d` and `/boot/grub/`. After
that, we might describe our [network
configuration](https://github.com/jeaye/nix-files/blob/master/network.nix),
which includes a firewall. We can describe [each
user](https://github.com/jeaye/nix-files/blob/master/user.nix) and the groups
they're in, the permissions they have, their shell, home directory, etc.

Once the base system is setup, we can describe [how we want X to
behave](https://github.com/jeaye/nix-files/blob/master/x11.nix), which even
includes installing proprietary drivers and setting up kernel modules, if
needed. From there, specifying any number of packages we want and any
configurations we want for them is entirely up to what's described in the Nix
files.

Once you're in a NixOS machine, you can change your configs and then just run
`nixos-rebuild switch` and Nix will realize everything you described, even if it
means building a new kernel, bringing in new software, dependencies, upgrading
something, or completely removing large portions of the system.

An example of just how simple something like a kernel upgrade can be: [this
commit upgrades my machine to Linux
4.2.x](https://github.com/jeaye/nix-files/commit/03fe9397337d13b65700b555525de047760314a5).
No longer should you have to waste time reconfiguring machines to be similar to
other machines you've setup.

### My thoughts
Though it may sound like I'm just trying to sell NixOS here, I'm not actually
using it anymore (was on Slackware, but I put Arch on after NixOS). Why not?
First, I want to say more about what I love with regard to Nix and NixOS.

* Easy install of any packaged software (steam, skype, etc)

  * By just describing that the package should be installed, in your Nix files,
    and telling Nix to realize what you described, you can completely rework
    your system

* Seemingly large changes, like a kernel update are often a one-liner
* Your entire system is stored in configuration files which can easily be put
  onto Github or similar

  * Once you describe a machine, you can replicate it anywhere. If you lose that
    machine, the configs will bring you back to where you need to be.

* Upgrades are atomic and you can rollback any changes. By default, when you
  tell NixOS to realize your configs, it takes a snapshot of your current
  configs and updates GRUB so you can even choose previous setups at boot.

* Installation is a breeze; I installed NixOS from my existing Slackware
  install.

* The IRC channel on Freenode, #nixos, is quite active and helpful

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
