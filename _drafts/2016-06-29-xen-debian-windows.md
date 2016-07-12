---
title: Installing Arch Linux with a fully-encrypted disk
tags: [arch, linux, tutorial, security, encryption, disk]
---

### Why encrypt?
On a typical GNU/Linux install, you won't have disk encryption. Though you're a
keen user and you've chosen a very strong passphrase (TODO link), your data is
still stored openly. Should anyone steal, confiscate, buy, or otherwise obtain
your hard drive, every bit of data is going to be readable. Should anyone boot
into a live CD on your system and mount your drives, your data is readily
available and your strong passphrase is none the wiser.

### Varying degrees of encryption
It's becoming more popular to encrypt certain files, perhaps using GPG (TODO
link), or perhaps your whole home directory. This still suffers, compared to
full system encryption, since the entire root of the file system is still open.
Directories like `/etc`, where the majority of your system configurations exist
(often including sensitive information), `/var`, where sensitive data may be
logged by running processes, and even `/tmp`, where processes may store
sensitive temporary data.

*Encrypt first, then install; use your system with more confidence.*

### Start here
Let this be a guide for your next bare-bones Arch setup. I assume you're the
root user unless otherwise specified.

#### Dowload
Head over to https://www.archlinux.org/download/ and download the latest ISO,
preferably via BitTorrent. Burn it to your external media in your preferred
manner; I have a 16GB USB drive at `/dev/sdb`, in this example, and I'll make my
live disk with one command.

```bash
$ dd if=archlinux-2016.07.01-dual.iso of=/dev/sdb bs=1M
```

Boot into your new live CD, choose the boot into Arch, and you'll be dropped at
a root prompt. Now you'll create your system.

#### Partition
I'm assuming you're installing to `/dev/sda`; the resulting partition table is
shown below.

|Partition    |Mountpoint |Size      |
|:------------|:----------|:---------|
| `/dev/sda1` | `/boot`   | 200MB    |
| `/dev/sda2` | `/`       | Rest     |

Spin up cfdisk and create a matching layout.

```bash
$ cfdisk
```

#### Encrypt
Now, before you install anything, you're going to setup encryption for
`/dev/sda2`. Choose a strong passphrase, at least 32 characters long. I
recommend using a complete sentence with spaces, punctuation, and mixed case. As
the disk is encrypted, it'll first be scrubbed with random data. You can
interrupt this, but you should not! Here's why.

Typical data can be discovered by patterns that are inherent to its format.
(TODO link) Video, audio, source code, etc, each looks different as a pattern of
bits. Encrypted data typically looks like random garbage. As a result, if you
only encrypt the data of this new system, there may be old data on the drive
which will not look random; it'll still be decipherable as video, audio, etc. If
you randomize the whole drive first, then it's substantially more difficult to
tell where the encrypted data stops, since it all looks like random garbage.

```bash
$ cryptsetup --verbose --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat /dev/sda2
```

Given an encrypted partition, which `/dev/sda2` now is, you can decrypt it into
a labeled volume. In this example, you'll decrypt the fresh `/dev/sda2` into
`/dev/mapper/cryptroot`.

```bash
$ cryptsetup open --type luks /dev/sda2 cryptroot
```

Once it's there, you're free to mount it, format it, or do just about anything
you would with a normal disk partition.


#### Format
Both of the partitions will just use [Ext4](https://en.wikipedia.org/wiki/Ext4),
in this example. You're welcome to use any file system you'd like.

```bash
$ mkfs.ext4 /dev/sda1
$ mkfs.ext4 /dev/mapper/cryptroot
```

Once you have your file systems formatted, they should be mounted in a local
directory. You'll change root into here soon.

```bash
$ mkdir -p mnt
$ mount -t ext4 /dev/mapper/cryptroot mnt
$ mkdir -p mnt/boot
$ mount -t ext4 /dev/sda1 mnt/boot
```

#### Install the base system
The Arch live system comes with a couple of commands to help bootstrap your new
system. The first you'll use is `pacstrap`, which takes the directory in which
to install and an arbitrary number of packages. This requires network access and
I recommend installing some basic tools which will help as you build up your
system. Aside from the required `base` and `base-devel`, I opt for `vim` and
`tmux`.

```bash
$ pacstrap -i mnt base base-devel vim tmux
```

Your current mount points will work as a starting point for the new system, so
you can serialize them as an fstab now.

```bash
$ genfstab -U -p mnt >> mnt/etc/fstab
```

#### Enter the system
At this point, a working user-space is within `mnt`, and you an change root into
it. Arch provides a custom `arch-chroot` for this purpose; it's a helper script
around `chroot` which also sets up certain API file systems and makes
`/etc/resolv.conf` available.

```bash
$ arch-chroot mnt
```

#### Setup locale
A modern setup should default to UTF-8 (TODO link).

```bash
$ sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/g' /etc/locale.gen
$ locale-gen

$ echo LANG=en_US.UTF-8 > /etc/locale.conf
$ export LANG=en_US.UTF-8
```

#### Setup time
Link in the appropriate time zone for you. I also recommend keeping the hardware
clock on UTC.

```bash
$ ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

$ hwclock --systohc --utc
```

echo xen-master > /etc/hostname

passwd # enter root password

useradd -m -g users -G wheel -s /bin/bash penny
passwd penny # enter user's password

visudo # uncomment wheel

pacman -S grub-bios
sed -i 's#^\(GRUB_CMDLINE_LINUX="\)#\1cryptdevice=/dev/sda2:cryptroot#' /etc/default/grub

sed -i 's/^\(HOOKS=".*\)\(filesystems.*\)/\1 encrypt \2/' /etc/mkinitcpio.conf
mkinitcpio -p linux

grub-install --recheck /dev/sda
grub-mkconfig --output /boot/grub/grub.cfg

exit
umount -R mnt/boot
umount -R mnt
cryptsetup close cryptroot
reboot

TODO: When locked out of the system, these commands will help
