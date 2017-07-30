---
title: "NixOS: lasting impression"
tags: [linux, nixos, nix, review]
---

Two years ago, I wrote about [my first impression of NixOS]({{ site.blog_url
}}/2015/11/24/nixos/), as I was using it in my workstation. While I adored the
concept of declarative OS configuration, it didn't quite fit the workflow I had
in mind for my laptop. The post was finished with me considering NixOS for my
VPS, but I didn't quite want to move away from DigitalOcean, which has support
for only a few distros. What follows details how I've been running NixOS since,
what it took, and what I've learned.

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

### Setting up complex services
Once NixOS was running on my DigitalOcean droplet, I had the work of porting all
of the services I was running on my Arch droplet to a declarative setup which I
could easily version with git. Here are some of the services I'm running, as
well as the related configs for each.

* [apache-httpd](https://github.com/jeaye/nix-files/blob/master/service/httpd.nix)
* [fail2ban](https://github.com/jeaye/nix-files/blob/master/service/fail2ban.nix)
* [dovecot](https://github.com/jeaye/nix-files/blob/master/service/dovecot.nix)
* [postfix](https://github.com/jeaye/nix-files/blob/master/service/postfix.nix)
* [radicale](https://github.com/jeaye/nix-files/blob/master/service/radicale.nix)

For the most part, setting up a service on NixOS is similar to setting it up on
any normal distro. The difference is that one generally is limited to the API
provided by that NixOS service. Unlike packages, in Nix and NixOS, services
can't be overridden. This has only been an issue once, in the past couple
years, but it's currently limiting my ability to configure
[spamassassin](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/mail/spamassassin.nix)
right now (`master` has a much better interface than `17.03`, so I need to wait
until `17.09` unless I want to run from `master` -- I don't).

I tend to forget things, like what I've setup on a machine, or everything that
was required to get a service running, so having it all in plain text, and
version control, in a reproducible fashion, is ideal.

### Manager user homes
NixOS doesn't provide a way to declaratively manage user homes. In fact, the
only direct control it provides, declaratively, is over what's in `/etc` and its
subdirectories. There have been some approaches and discussions (like
[here](https://github.com/NixOS/nixpkgs/issues/1750) and
[here](https://github.com/NixOS/nixpkgs/pull/9250)), but I opted for a much
simpler solution, which was already supported at the time. NixOS forfeits the
conventional ideas of where programs live and how they're installed and
upgraded, so why not take that liberty with user homes?

So, since NixOS provides declarative management of `/etc` and its subdirectories, I just use `/etc/user` as my analogous `/home`. For example, the user `irc`, [defined here](https://github.com/jeaye/nix-files/blob/master/user/jeaye.nix), is described as:

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

* No side effects in activation scripts
* Building leiningen projects with Nix is a pain (and it's slow to download deps
  again and again)
* Prefer Scheme/Guix to Nix
* Guix's free software is more appealing
* Can't disable X without having to compile a ton of openjdk + more
* User home management in /etc
* Ensuring directories exist with `.manage-directory`
* Some packages move too slowly, so I need to pull from unstable
* IRC channel is still super helpful
