---
title: Upgrading System76 firmware on Arch
labels: [linux, tutorial, security, privacy]
tags: [system76, firmware, ime, arch]
---

In the wake of the Intel Management Engine security revelations,
[System76](https://system76.com/) developed a firmware upgrade for all of its
machines and released an [update
plan](http://blog.system76.com/post/168050597573/system76-me-firmware-updates-plan)
in November 2017. In February 2018, owners of the [Oryx
Pro](https://system76.com/laptops/oryx) were informed that the firmware update
was available through System76's open source firmware updater. For anyone not on
Systm76's [Pop!_OS](https://system76.com/pop) or similar Debian-based distros,
this firmware updater probably didn't do *anything*. After waiting patiently for
a couple of months for more updates and not seeing any fixes, I dug into why the
how I could get things going. Herein lies the easiest way, for me, that it can
be done.

```
2018-04-08 10:48:51,895  INFO  Verified manifest signature...
2018-04-08 10:48:51,895  INFO  Fetching f7cd3816401c6ab1cd2f0a83285a56ee432a9736b707870fb7aeb34c2750bcefc2adcf0f83952696eb688b9768e93f68 with cache /var/cache/system76-firmware
2018-04-08 10:48:51,897  INFO  Fetching e4206477b3f5bad09d54363a78ae79e2916127399e9725c3b9d77bf229c25c293111926d841c1c05b186a96c0963f6ff with cache /var/cache/system76-firmware
2018-04-08 10:48:51,933  INFO  Fetching ec0b0b475412acde6b2b9a05647a64f48beaa5baea298e8801ce1a34bbddcdada5fc2d8025b2e6f07d9802c384a01e7c with cache /var/cache/system76-firmware
2018-04-08 10:48:52,262  INFO  Verified manifest signature...
2018-04-08 10:48:52,263  INFO  Fetching f7cd3816401c6ab1cd2f0a83285a56ee432a9736b707870fb7aeb34c2750bcefc2adcf0f83952696eb688b9768e93f68 with cache /var/cache/system76-firmware
2018-04-08 10:48:52,265  INFO  Fetching e4206477b3f5bad09d54363a78ae79e2916127399e9725c3b9d77bf229c25c293111926d841c1c05b186a96c0963f6ff with cache /var/cache/system76-firmware
2018-04-08 10:48:52,299  INFO  Fetching ec0b0b475412acde6b2b9a05647a64f48beaa5baea298e8801ce1a34bbddcdada5fc2d8025b2e6f07d9802c384a01e7c with cache /var/cache/system76-firmware
```

mv /boot/efi/system76-firmware-update /boot/efi/EFI/

rescatux

```
menuentry "System76 Firmware Update" {
        insmod chain
        insmod search_fs_uuid
        search --fs-uuid --no-floppy --set=root 129D-B845
        chainloader /EFI/system76-firmware-update/boot.efi
}
```

```bash
cfdisk /dev/nvme0n1
mount /dev/nvme0n1p1 /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
```

```
efibootmgr -c -b 1776 -l '\\system76-firmware-update\\boot.efi' -L "system76-firmware-update"
Could not prepare Boot variable: No such file or directory
```

efi install worked once, with some GPT warnings. After a reboot, I still went right to grub.

After starting the update, it'll reboot once. At grub, select the updater entry again.

Once the update completed, HDMI no longer worked. xrandr doesn't show my
external monitor as connected.
