---
title: Running GNU/Linux and Windows simultaneously (no VM)
tags: [linux, windows, xen, tutorial, vm]
---

For my wife's latest setup, I explored the Xen hypervisor and aimed to provide
her with a GNU/Linux host machine which could also run Windows 7
simultaneously, with each OS having its own dedicated GPU and display. Below, I
detail the steps I took, from start to finish.

### Installing Debian stable
[Debian](https://www.debian.org/) sits in a middle ground between my wife's
desire for avoiding the command line and my desire for a distro which respects
privacy and embraces free software. This setup isn't limited or specific to
Debian, however. The latest Debian (8.5.0 at the time of writing) AMD64 ISOs
are available, via torrent,
[here](http://cdimage.debian.org/debian-cd/current-live/amd64/bt-hybrid/).

The installation of Debian is [nicely documented](https://www.debian.org/releases/stable/amd64/), so I'll only point out notable changes in my setup and otherwise assume a normal installation.

#### Setting up the disk
During the disk partitioning step of the installation, I enabled full disk
encryption using LVM. This isn't needed for the Xen setup, but it's recommended
for the protection of your data.

I also opted to have `/home` on its own partition, since that allows for easier
changing of `/` while keeping users exactly as they were.

#### Choosing a desktop environment
As with most aspects in the GNU/Linux world, there's a good deal of
fragmentation with desktop environments. As my wife doesn't want anything
special, I went with GNOME. KDE, XFCE, and GNOME are all fine choices; for
those who like Unity, there have been [privacy
concerns](https://en.wikipedia.org/wiki/Unity_(user_interface)#Criticism) worth
noting.

### Installing nVidia drivers
I know my current hardware, so finding the right driver for it isn't an issue. If you're not sure, however, you can use the `nvidia-detect` tool:

```bash
$ aptitude update
$ aptitude install nvidia-detect
$ nvidia-detect
```

**NOTE:** You'll need to add `contrib non-free` to each source in your `/etc/apt/sources.list` (you likely also want to comment out the `cdrom` entry) before issuing these commands.

I issued the following, to get the nVidia ball rolling. Depending on your card series, you may not need this legazy version and `nvidia-driver` may work fine for you.

```bash
$ aptitude update
$ aptitude install linux-headers-$(uname -r | sed 's,[^-]*-[^-]*-,,') nvidia-legacy-304xx-kernel-dkms xserver-xorg-video-nvidia-legacy-304xx nvidia-support xserver-xorg-dev
```

The `Conflicting nouveau kernel module loaded` warnings are expected. I next
jotted down the new Xorg config. There's an `nvidia-xconfig` tool, but it's
only available for the newest version of the nVidia driver and breaks
everything horrifically if you're using the legacy driver. I recommend just
specifying the following in `/etc/X11/xorg.conf.d/20-nvidia.conf`:

```text
Section "Device"
  Identifier "Nvidia Card"
  Driver "nvidia"
  VendorName "NVIDIA Corporation"
  Option "NoLogo" "true"
EndSection
```

Reboot after creating the X configs to jump into the new driver.

```bash
$ reboot
```

Once the system comes back up, you can verify that your nVidia drivers are
operational. The following should return your driver number (304.131 in my
case) and some more info about your card.

```bash
$ glxinfo | grep "core profile version"
OpenGL core profile version string: 4.2.0 NVIDIA 304.131
```

### Installing Xen
Xen will be the foundation of this project, so it's the next package to come
after the video drivers are setup.

```bash
$ aptitude install xen-linux-system
```

You can double check that your CPU supports hardware assisted virtualization
(should output vmx for Intel and svm for AMD, if HVM is supported):

```bash
$ egrep -o '(vmx|svm)' /proc/cpuinfo
```

If you were to reboot now, GRUB would show you an option for the Xen-enabled Linux kernel; alas, we want that option to be selected by default. The default should be updated before rebooting.

```bash
$ dpkg-divert --divert /etc/grub.d/08_linux_xen --rename /etc/grub.d/20_linux_xen
$ update-grub
$ reboot
```

Origin EON17-SLX
32GB DDR4 RAM
Core i7-3940XM @ 3.00GHz
2x GeForce GTX 670MX (SLI)
Corsair Neutron 240GB SSD
1TB Generic HDD

https://wiki.debian.org/VGAPassthrough



------------------ Arch linux

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

passwd

useradd -m -g users -G wheel -s /bin/bash penny
passwd penny

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

# log in as root

pacman -S plasma-desktop sddm konsole xorg-server-utils xorg-xinit

systemctl start sddm
# enable if everything works

# enable multi-lib
printf "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf
pacman -Syu

# build xen
su - penny
curl https://gitlab.com/johnth/aur-xen/repository/archive.zip?ref=master > aur-xen.zip
unzip aur-xen.zip ; cd aur-xen*
makepkg -s PKGBUILD
sudo pacman -U xen-*.xz

# TODO add dom0_mem=XXXM,max:XXXM to /etc/default/grub

sudo grub-mkconfig --output /boot/grub/grub.cfg
sudo reboot

/etc/init.d/xencommons start
xl list # should prove Xen is running properly

lspci | grep VGA
01:00.0
02:00.0

lspci | grep 02:00.
02:00.0 VGA
02:00.1 Audio

#### Fill out windows-7 config
# name = "windows-7"
# builder = "hvm"
# memory = 4096
# vcpus = 4
# disk = [ "file:/root/domU/windows-7.img,hda,w",
#          "file:/root/domU/windows-7-sp1-x64.iso,hdc:cdrom,r" ]
# boot = "d"
# device_model_version = "qemu-xen-traditional"
# acpi = 1
# sdl = 0
# serial = "pty"
# vnc = 1
# vnclisten = "0.0.0.0"
# vncdisplay = 1

truncate -s 20G windows-7.img
xl create windows-7.cfg
xl list

pacman -S tigervnc
vncviewer 0.0.0.0:1 # Go through install process

su - penny
gpg --list-keys # Generate GPG database
echo "keyring /etc/pacman.d/gnupg/pubring.gpg" >> ~/.gnupg/gpg.conf

# In order to mount the windows image
cd ; mkdir pkg ; cd pkg
wget https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz
tar xvf cower.tar.gz
makepkg -s PKGBUILD
sudo pacman -U cower-16*.xz

wget https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz
tar xvf pacaur.tar.gz
makepkg -s PKGBUILD
sudo pacman -U pacaur-*.xz
exit # back to root

pacaur -S multipath-tools
kpartx -a windows-7.img
  mkdir -p mnt
  mount /dev/mapper/loop1p2 mnt
    # Read-only access files to (non-live) Windows machine
  umount mnt
kpartx -d windows-7.img

# Network link
ip link add name xenbr0 type bridge
ip link set xenbr0 up
ip link set enp4s0f2 master xenbr0
bridge link

# Unlink
ip link set enp4s0f2 nomaster
ip link delete name xenbr0 type bridge

### Add to windows-7.cfg
# vif = [ "bridge=xenbr0" ]
```

http://mirror.corenoc.de/digitalrivercontent.net/
