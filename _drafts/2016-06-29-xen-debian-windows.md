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

### Installing
Let this be a guide for your next bare-bones Arch setup. I'm assuming we're
installing to `/dev/sda`; the partition table will look like this:

|Partition    |Mountpoint |Size      |
|:------------|:----------|:---------|
| `/dev/sda1` | `/boot`   | 200MB    |
| `/dev/sda2` | `/`       | Rest     |

```bash
cfdisk # setup sda1, sda2

cryptsetup --verbose --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat /dev/sda2
cryptsetup open --type luks /dev/sda2 cryptroot

mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/mapper/cryptroot

mount -t ext4 /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount -t ext4 /dev/sda1 /mnt/boot

pacstrap -i /mnt base base-devel vim tmux htop

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt

sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/g' /etc/locale.gen
locale-gen

echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

hwclock --systohc --utc

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
umount -R /mnt/boot
umount -R /mnt
cryptsetup close cryptroot
reboot
