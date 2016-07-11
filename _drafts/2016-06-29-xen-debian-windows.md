---
title: Installing Arch Linux with a fully-encrypted disk
tags: [linux, windows, xen, tutorial, vm]
---

Disk:
  /dev/sda1 => /boot (200MB)
  /dev/sda2 => / (rest)

```bash
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
