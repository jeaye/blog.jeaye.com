---
title: "NixOS: A lasting impression"
labels: [linux, nixos, nix, review]
tags: [linux, nixos, nix, review, digital ocean, functional programming]
---

Two years ago, I wrote about [my first impression of NixOS]({{ site.blog_url }}2015/11/24/nixos/),
as I was using it in my workstation. While I adored the concept of declarative
OS configuration, it didn't quite fit the workflow I had in mind for my laptop.
The post was concluded with me considering NixOS for my VPS, but I didn't quite
want to move away from DigitalOcean, which has support for only a few distros.
What follows details how I've been running NixOS since, what it took, and what
I've learned.

### Dealing with DigitalOcean
My VPS is hosting this blog, [jeaye.com](https://jeaye.com/), and many other
sites and services. For this, I use DigitalOcean. Ever since I started with
DigitalOcean a few years ago, they've been joy to work with, so I really didn't
want to leave. Alas, they don't support many distros, and certainly not custom
ISOs. The first droplet I was administrating was already going against the
grain, running Arch using [a script which converts Debian to Arch in
place](https://github.com/gh2o/digitalocean-debian-to-arch).

*"What a neat idea,"* I thought, *"to trick DigitalOcean into thinking it's
running a supported distro."* A couple weeks later,
[nixos-in-place](https://github.com/jeaye/nixos-in-place) was born; it remains
the most stable solution for converting any running GNU/Linux setup to NixOS in
place.

### Setting up complex services
Once NixOS was running on my DigitalOcean droplet, I had the work of porting all
of the services I was running on my Arch droplet to a declarative setup which I
could easily version with git. Here are some of the services I'm running, as
well as the related configs for each.

* [apache-httpd](https://github.com/jeaye/nix-files/blob/e3bf921a5af925465d8f41ec006c87c8f0ffafe3/service/httpd.nix)
* [fail2ban](https://github.com/jeaye/nix-files/blob/e3bf921a5af925465d8f41ec006c87c8f0ffafe3/service/fail2ban.nix)
* [dovecot](https://github.com/jeaye/nix-files/blob/e3bf921a5af925465d8f41ec006c87c8f0ffafe3/service/dovecot.nix)
* [postfix](https://github.com/jeaye/nix-files/blob/e3bf921a5af925465d8f41ec006c87c8f0ffafe3/service/postfix.nix)
* [radicale](https://github.com/jeaye/nix-files/blob/e3bf921a5af925465d8f41ec006c87c8f0ffafe3/service/radicale.nix)

For the most part, setting up a service on NixOS is similar to setting it up on
any normal distro. The difference is that one generally is limited to the API
provided by that NixOS service. Unlike packages, in Nix and NixOS, services
can't be overridden. This has only been an issue once, in the past couple
years, but it's currently limiting my ability to configure
[spamassassin](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/mail/spamassassin.nix)
(`master` has a much better interface than `17.03`).

I tend to forget things, like what I've set up on a machine, or everything that
was required to get a service running, so having it all in plain text, and
version control, in a reproducible fashion, is ideal.

### Managing user homes
NixOS doesn't provide a way to declaratively manage user homes. In fact, the
only direct control it provides, declaratively, is over what's in `/etc` and its
subdirectories. There have been some approaches and discussions (like
[here](https://github.com/NixOS/nixpkgs/issues/1750) and
[here](https://github.com/NixOS/nixpkgs/pull/9250)), but I opted for a much
simpler solution, which was already supported at the time. NixOS forfeits the
conventional ideas of where programs live and how they're installed and
upgraded, so why not take that liberty with user homes?

So, since NixOS provides declarative management of `/etc` and its subdirectories, I just use `/etc/user` as my analogous `/home`. For example, the user `jeaye`, [defined here](https://github.com/jeaye/nix-files/blob/e3bf921a5af925465d8f41ec006c87c8f0ffafe3/user/jeaye.nix), is described as:

```nix
users.users.jeaye =
{
  isNormalUser = true;
  home = "/etc/user/jeaye";
  createHome = true;
  extraGroups = [ "wheel" ];
};
```

If I want to put anything in the home directory for `jeaye`, I can do so
declaratively, like so:

```nix
environment.etc =
{
  "user/jeaye/.procmailrc" =
  {
    text =
    ''
      INCLUDERC=/etc/user/jeaye/.procmail/list.rc
      INCLUDERC=/etc/user/jeaye/.procmail/work.rc
      INCLUDERC=/etc/user/jeaye/.procmail/admin.rc
    '';
  };
};

```

I also use a trick to ensure directories exist, which just involves
declaratively putting a hidden file in there. NixOS will create any parent
directories needed.

```nix
# Ensure that the /etc/user/safepaste/paste directory exists
environment.etc."user/safepaste/paste/.manage-directory".text = "";
```

### Sticking with mainstream configuration to avoid compilations
Initially, I was amazed that my VPS was regularly spending an hour compiling
[OpenJDK](https://en.wikipedia.org/wiki/OpenJDK) every time I updated. After
further investigation, in the helpful `#nixos` IRC channel on Freenode, it seems
this is because I had disabled X everywhere I could. On a headless server, this
seemed intuitive. Unfortunately, [NixOS Hydra](https://nixos.org/hydra/),
which builds all of NixOS' deterministic binaries, only builds with so many
configurations. As one can imagine, each new configuration added for a build,
with the various platforms, architectures, and other configurations, expands the
build time exponentially. As such, the VPS now runs with [environment.noXlibs
set to
false](https://github.com/jeaye/nix-files/blob/e3bf921a5af925465d8f41ec006c87c8f0ffafe3/system/environment.nix#L26).

### Hitting the network in an activation script
I had an upgrade script, which I was running in `system.activationScripts`, that
hit the network to check for upgrades. While the machine was already running,
this posed no problem at all and worked quite nicely. Whenever I would
`nixos-rebuild switch`, the activation script would run and upgrade the package
if needed. Alas, during a routine reboot, I was no longer able to boot even into
a shell; the kernel would panic. After several hours of painstaking debugging
with a custom initrd, it turns out the problem was that the activation script
hitting the network was failing, since there was no network, and the rest of the
boot would then fail.

In short, leave network IO out of activation scripts; I'm using a cron job, for
this task, instead. Simple enough.

### Building Clojure packages with Leiningen
When bringing in some of my Clojure services, there were issues with compiling
Leiningen projects, due to the dependency downloading. By default, the home of
the Nix builder isn't writable, so some workarounds are needed. This setup has
been working for me (as part of your typical Nix package):

```nix
buildInputs = [ pkgs.leiningen ];
buildPhase =
''
  # For leiningen
  export HOME=$PWD
  export LEIN_HOME=$HOME/.lein
  mkdir -p $LEIN_HOME
  echo "{:user {:local-repo \"$LEIN_HOME\"}}" > $LEIN_HOME/profiles.clj

  ${pkgs.leiningen}/bin/lein uberjar
'';
```
### Pulling from unstable when packages are too old
Occasionally, a package in the Nix repos for a given release, like `17.03`, will be too old, have a bug, etc. If NixOS `master` has a fix for this, it might be worthwhile to bring in the `master` version of just that package, not your whole OS. Due to the elegance of Nix's dependency management, this isn't a problem at all; the `unstable` channel follows each successful build of the `master` branch, so we can just pull that in. Say we wanted to do this for [weechat](https://weechat.org/).

```nix
environment.systemPackages = let pkgsUnstable = import
(
  fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
)
{ };
in
[
  pkgsUnstable.weechat
];
```

Once the next version has been released, or the fix has been added to your
default channel, then this can go back to normal.

```nix
environment.systemPackages =
[
  pkgs.weechat
];
```

### Minimizing used disk space
If left on its own, NixOS can be quite greedy with disk space. This is primarily
a trade-off for the convenience of a purely functional package infrastructure,
but it's still worth noting how it can be managed. The following bits have
helped keep my system pretty lean (`/nix` is 5.4G).

```nix
# Auto GC every morning
nix.gc.automatic = false;
services.cron.systemCronJobs = [ "0 3 * * * root /etc/admin/optimize-nix" ];

environment.etc =
{
  "admin/optimize-nix" =
  {
    text =
    ''
      #!/run/current-system/sw/bin/bash
      set -eu

      # Delete everything from this profile that isn't currently needed
      nix-env --delete-generations old

      # Delete generations older than a week
      nix-collect-garbage
      nix-collect-garbage --delete-older-than 7d

      # Optimize
      nix-store --gc --print-dead
      nix-store --optimise
    '';
    mode = "0774";
  };
};
```

### Various nitpicks which could improve the NixOS user's experience
* Calculating SHA-256 of a package isn't easy

    It seems like the best way to do this is to put in a bad SHA-256, try to
    build, have it fail and tell you the correct one, and then put it in.

* Nix command-line UI needs a re-design

    This is a [known issue](https://github.com/NixOS/nix/issues/779) but, after
    nearly two years, has not yet been merged. In short, commands like `nix-env
    -qa` would become `nix search` and `nix-env -qc` would become `nix status`.
    There's no reason users should have to remember, or learn, the former.

* Editor support for Nix and Nixpkgs

    Yes, there are Nix plugins for every good editor. What I haven't seen any
    formal discussion about, but could help Nix along, is a more functional
    integration into those editors. I think [Emacs is currently best
    posed](https://github.com/matthewbauer/nix-mode), in this regard, but
    providing semantic completion of all the items in
    [nixpkgs](https://github.com/NixOS/nixpkgs), completion for dependency
    injection and Nix's standard library, semantic highlighting, linting,
    SHA-256 calculation (when writing packages), etc., might really help users
    jump into the Nix world.

* Declaring private data

    This is something I've yet to tackle. Instead, there are various places within
    my NixOS files which are marked as `XXX`, with a comment saying what I need to
    do. These comments represent imperative steps I need to take when deploying this
    configuration to a new machine. Currently, this just entails setting up private
    keys, [htpassword](https://en.wikipedia.org/wiki/.htpasswd) files, and some
    private git repos which I host. A possible solution for passwords, and the like,
    may be to commit them to git after GPG-encrypting them. For everything else,
    perhaps a GPG-encrypted bash script in the repo, which does the remaining setup
    interactively, would suffice.

### Considering what's left and how things are
It's been two years with NixOS on my VPS and they've been great. My biggest
complaints are in the form of the Nix expression language itself not being very
easy to use, having a good standard library, and having much documentation on
doing generic tasks. In this regard, I think that
[GuixSD](https://www.gnu.org/software/guix/) is much more appealing: it uses
[Guile Scheme](https://www.gnu.org/software/guile/), which has clear practical
applications and is a much more general-purpose language that system
administrators might even already know.

Guix's stance on free software, due to it being a GNU project, is also more
appealing; my VPS has absolutely no need for proprietary software (it's only
somewhat harder to argue that for my workstation).

I very much plan to keep NixOS running on my VPS and switching as much as I can
to the declarative style. After having such great success in the server world,
I've been thinking more about trying it again for my workstation. Alas, I think
my issues would the Nix language would bug me enough to where that wouldn't be
enjoyable. If I can work out getting Skype (and maybe nVidia) on GuixSD, or
maybe if [GNU Ring](https://ring.cx/en) stabilizes enough, then I'd really enjoy
having a declarative workspace in very much the same fashion. Maybe in two years
I'll be following up with my thoughts on that.
