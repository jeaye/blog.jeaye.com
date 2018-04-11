---
title: Upgrading System76 firmware on Arch
labels: [linux, tutorial, security, privacy]
tags: [system76, firmware, ime, arch]
---

In the wake of the [Intel Management
Engine](https://en.wikipedia.org/wiki/Intel_Management_Engine) security
revelations, [System76](https://system76.com/) developed a firmware upgrade for
all of its machines and released an [update
plan](http://blog.system76.com/post/168050597573/system76-me-firmware-updates-plan)
in November 2017. In February 2018, owners of the [Oryx
Pro](https://system76.com/laptops/oryx) were informed that the firmware update
was available through System76's open source firmware updater. For anyone not on
Systm76's [Pop!_OS](https://system76.com/pop) or similar Debian-based distros,
this firmware updater probably didn't do *anything*. After waiting patiently for
a couple of months for more updates and not seeing any fixes, I dug into how I
could get things going. Herein lies the easiest way I found.

### Silent errors when running
The [system76-driver AUR
package](https://aur.archlinux.org/packages/system76-driver/) provides a systemd
service which just runs the `system76-firmware` command to check for firmware
updates. In my case, when I ran it, I saw something like the following:

```
$ system76-firmware
2018-04-08 10:48:51,895  INFO  Verified manifest signature...
2018-04-08 10:48:51,895  INFO  Fetching f7cd3816401c6ab1cd2f0a83285a56ee432a9736b707870fb7aeb34c2750bcefc2adcf0f83952696eb688b9768e93f68 with cache /var/cache/system76-firmware
2018-04-08 10:48:51,897  INFO  Fetching e4206477b3f5bad09d54363a78ae79e2916127399e9725c3b9d77bf229c25c293111926d841c1c05b186a96c0963f6ff with cache /var/cache/system76-firmware
2018-04-08 10:48:51,933  INFO  Fetching ec0b0b475412acde6b2b9a05647a64f48beaa5baea298e8801ce1a34bbddcdada5fc2d8025b2e6f07d9802c384a01e7c with cache /var/cache/system76-firmware
2018-04-08 10:48:52,262  INFO  Verified manifest signature...
2018-04-08 10:48:52,263  INFO  Fetching f7cd3816401c6ab1cd2f0a83285a56ee432a9736b707870fb7aeb34c2750bcefc2adcf0f83952696eb688b9768e93f68 with cache /var/cache/system76-firmware
2018-04-08 10:48:52,265  INFO  Fetching e4206477b3f5bad09d54363a78ae79e2916127399e9725c3b9d77bf229c25c293111926d841c1c05b186a96c0963f6ff with cache /var/cache/system76-firmware
2018-04-08 10:48:52,299  INFO  Fetching ec0b0b475412acde6b2b9a05647a64f48beaa5baea298e8801ce1a34bbddcdada5fc2d8025b2e6f07d9802c384a01e7c with cache /var/cache/system76-firmware
$ echo $?
0
```

No errors, no warnings, a clean exit code, but it didn't update my firmware or
give me any insight into how or when that was going to happen. This is how
things were since the `system76-firmware` command was added to the AUR package.

### Issues with the display
When deciding to dig into what was going on, the first thing I did was step
through the program with [pdb](TODO). From there, it became clear that
`system76-firmware` is trying to show a modal, but can't find the display name,
so it [exits silently](TODO). It's reading the display name from `who`, which is
odd, since I'd think it'd just check `DISPLAY`, so I just edited the source to
just return `:0`, which is the value of `echo $DISPLAY` in my X session. Looks
like this is just an assumption made on System76's part.

For the file: `/usr/lib/python3.6/site-packages/system76driver/firmware.py`
```diff
diff --git a/firmware.py b/firmware.py
index 95bafe1..90c60f9 100644
--- a/firmware.py
+++ b/firmware.py
@@ -444,6 +444,7 @@ def get_user_session():
                     "who | awk -v vt=tty$(fgconsole) '$0 ~ vt {print $5}'",
                     shell=True
                 ).decode('utf-8').rstrip('\n').lstrip('(').rstrip(')')
+    display_name = ":0" # XXX: Hack
 
     user_pid = subprocess.check_output(
                     "who -u | awk -v vt=tty$(fgconsole) '$0 ~ vt {print $6}'",
```

### Issues with efibootmgr
After that one line fix, running `system76-firmware` resulted in a modal! I
could choose to close the modal or click a button to install the firmware. After
trying to install, another modal shows up with the procedure instructions, as
they're also shown on the [System76 support page](TODO), and a button to restart
into the firmware updater. Restart!

...

Back into GRUB, then into Arch, with no firmware updates. Damn. So I dug more
into the source for, hopefully, another one liner. There's a bash script, as part
of the Python source, called [FIRMWARE_SET_NEXT_BOOT](TODO). This is what's
trying to make the next boot go into the updater's EFI file instead of the
normal boot order. So, already, there are some assumptions made.

1. The user is booting with EFI
2. `/boot/efi` is mounted
4. Writing the System76 updater EFI to `/boot/efi/system76-firmware-update/` is useful
3. `efibootmgr -C` is valid

For all but the first of these assumptions, on my Arch setup, System76 is
guessing incorrectly. Yes, I'm booting with EFI, but `/boot/efi` isn't always
mounted. Furthermore, the `system76-firmware-update` directory should be
installed into `/boot/efi/EFI` if it wants to actually be useful. Finally,
according to the `efibootmgr` man page, `-c` should be used to create boot
entries. `-C` doesn't exist. In your `system76-firmware` output, you'll probably
see something like this (from `efibootmgr`):

```text
Could not prepare Boot variable: No such file or directory
```

So, you might try the following, in order to get your restarts to bring you into
the updater:

1. Patch the [bash script](TODO) to use `-c` instead of `-C` with `efibootmgr`
2. Mount `/boot/efi` and *then* run `system76-firmware` (then see if it installs properly and try rebooting)
3. Move `/boot/efi/system76-firmware-update` to `/boot/efi/EFI/system76-firmware-update` and then run `system76-firmware` again, to see if `efibootmgr -c` picks it up and try your restart

I was able to get `efibootmgr` to finally run without error, but a restart still
just brought me to GRUB.

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


efi install worked once, with some GPT warnings. After a reboot, I still went right to grub.

After starting the update, it'll reboot once. At grub, select the updater entry again.

Once the update completed, HDMI no longer worked. xrandr doesn't show my
external monitor as connected.
