---
title: "Removing IME: Upgrading System76 firmware on Arch"
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
was available through System76's open source [firmware
updater](https://github.com/system76/firmware-update). For anyone not on
System76's [Pop!_OS](https://system76.com/pop) or similar Debian-based distros,
this firmware updater probably *didn't do anything*. After waiting patiently for
a couple of months for more updates and not seeing any fixes, I dug into how I
could get things going. Herein lies the easiest way I found.

### Before proceeding
To start with, try the firmware update normally, as recommended by the [System76
docs](http://support.system76.com/articles/laptop-firmware/). The approach I
took is pretty hacky, but it was the only thing which worked for my setup.
Ideally, you can take a more trodden route.

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
through the program with [pdb](https://docs.python.org/2/library/pdb.html). From
there, it became clear that `system76-firmware` is trying to show a modal, but
can't find the display name, so it [exits
silently](https://github.com/pop-os/system76-driver/blob/master_artful/system76driver/firmware.py#L467).
It's reading the display name from `who`, which is odd, since I'd think it'd
just check `DISPLAY`, so I edited the source to just return `":0"`, which is the
value of `echo $DISPLAY` in my X session. This could be because I'm running
[i3-wm](https://i3wm.org/) and not GNOME or KDE, but it's an assumption made on
System76's part either way.

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
they're also shown on the [System76 support
page](http://support.system76.com/articles/laptop-firmware/), and a button to
restart into the firmware updater. Restart!

...

Back into GRUB, then into Arch, with no firmware updates. Damn. So I dug more
into the source for, hopefully, another one liner. There's a bash script, as part
of the Python source, called
[FIRMWARE_SET_NEXT_BOOT](https://github.com/pop-os/system76-driver/blob/master_artful/system76driver/firmware.py#L206).
It looks like this:

```bash
EFIDEV="$(findmnt -n /boot/efi -o SOURCE)"
EFINAME="$(basename "${EFIDEV}")"
EFISYS="$(readlink -f "/sys/class/block/${EFINAME}")"
EFIPART="$(cat "${EFISYS}/partition")"
DISKSYS="$(dirname "${EFISYS}")"
DISKNAME="$(basename "${DISKSYS}")"
DISKDEV="/dev/${DISKNAME}"

echo -e "\e[1mCreating Boot1776 on "${DISKDEV}" "${EFIPART}" \e[0m" >&2
efibootmgr -B -b 1776 || true
efibootmgr -C -b 1776 -d "${DISKDEV}" -p "${EFIPART}" -l '\\system76-firmware-update\\boot.efi' -L "system76-firmware-update"

echo -e "\e[1mSetting BootNext to 1776\e[0m" >&2
efibootmgr -n 1776

echo -e "\e[1mInstalled system76-firmware-update\e[0m" >&2
efibootmgr -v
```

This is what's trying to make the next boot go into the updater's EFI file
instead of the normal boot order. So, already, there are some assumptions made.

1. The user is booting with EFI
2. `/boot/efi` is mounted
3. Writing the System76 updater EFI to `/boot/efi/system76-firmware-update/` is useful
4. `efibootmgr -C` is valid
5. Errors don't matter. They do though, so it should be using [safer
   settings](https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/).

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

1. Patch the [bash script](https://github.com/pop-os/system76-driver/blob/master_artful/system76driver/firmware.py#L224) to use `-c` instead of `-C` with `efibootmgr`
2. Mount `/boot/efi` and *then* run `system76-firmware` (then see if it installs properly and try rebooting)
3. Move `/boot/efi/system76-firmware-update` to `/boot/efi/EFI/system76-firmware-update` and then run `system76-firmware` again, to see if `efibootmgr -c` picks it up and try your restart

I was able to get `efibootmgr` to finally run without error, but a restart still
just brought me to GRUB. So, I took a more manual route.

### Before proceeding: get Rescatux
Very importantly, make sure you have a USB or CD/DVD with a burned image of
[Rescatux](https://www.supergrubdisk.org/rescatux/). Rescatux is an amazing 20MB
rescue boot image which can boot into most anything. This is not a precaution;
if you follow these steps, you *will* need Rescatux, so burn it now.

1. Download it [here](https://www.supergrubdisk.org/category/download/rescatuxdownloads/rescatux-beta/)
2. Burn with `dd` or whatever you prefer

### Manually loading the updater EFI
My idea was simple: just add a GRUB entry for the firmware updater, since I can
so reliably make it into GRUB. The catch is that the firmware updater, thinking
that it was booted from the temporary boot path made by the bash script
discussed above, deletes the EFI boot path which was used to boot. As long as
there's a Rescatux image lying around, though, that's not a problem.

#### Add the GRUB entry
The GRUB entry should look something like this (put it at the bottom of
`/etc/grub.d/40_custom`):

```text
menuentry "System76 Firmware Update" {
        insmod chain
        insmod search_fs_uuid
        search --fs-uuid --no-floppy --set=root TODO-ID
        chainloader /EFI/system76-firmware-update/boot.efi
}
```

In order for it to work for your machine, you need to do two things.

#### Find the filesystem UUID
Run `cfdisk <your disk>` and select your EFI partition to see its filesystem id.
For example, mine is `129D-B845`. Replace `TODO-ID` in the above GRUB entry with
your id. Here's what it should look like:

```text
$ cfdisk /dev/nvme0n1
                                   Disk: /dev/nvme0n1
                 Size: 232.9 GiB, 250059350016 bytes, 488397168 sectors
              Label: gpt, identifier: B7545E19-CF68-4779-BD95-F12C7DC8DDA6

    Device                 Start          End      Sectors      Size Type
>>  /dev/nvme0n1p1          2048      1050623      1048576      512M EFI System         
    /dev/nvme0n1p2       1050624    488397134    487346511    232.4G Linux filesystem
 ┌────────────────────────────────────────────────────────────────────────────────────┐
 │  Partition name: primary                                                           │
 │  Partition UUID: 7761E4D0-5726-45BE-9761-25FC114DE691                              │
 │  Partition type: EFI System (C12A7328-F81F-11D2-BA4B-00A0C93EC93B)                 │
 │ Filesystem UUID: 129D-B845                                                         │
 │Filesystem LABEL: EFI                                                               │
 └────────────────────────────────────────────────────────────────────────────────────┘
   [ Delete ]  [ Resize ]  [  Quit  ]  [  Type  ]  [  Help  ]  [  Write ]  [  Dump  ]

```

#### Move the updater to the EFI partition
As mentioned above, `system76-firmware` installs the updater to
`/boot/efi/system76-firmware-update`. If that's your EFI root, great. Just
update the GRUB entry to not use `/EFI/`. If your system is like mine, though,
you'll need to move the updater to `/boot/efi/EFI/system76-firmware-update`.

#### Generate GRUB's new config
With the new GRUB entry, the final step to get ready for the reboot is to
generate the new GRUB configs.

```bash
$ grub-mkconfig --output /boot/grub/grub.cfg
```

### Time to update the firmware
At this point, a reboot should bring you into GRUB with your new entry. After
selecting your new entry, you should see the updater and you can press enter to
continue. Remember to have the [System76
docs](http://support.system76.com/articles/laptop-firmware/) on hand, so you
understand how the update flow should go.

After a little while, the updater will reboot. Your fans will be on full blast.
**At the GRUB menu, choose the updater again.** Once you're back in the updater,
it'll work for a while more, run some checks, and finally power off. Follow the
System76 docs to jump into BIOS, adopt the defaults, and everything else. When
you're ready to get back into GNU/Linux, you'll find your EFI boot path is gone.

### Rescatux
Plug in your Rescatux media, reboot your machine, optionally hit F2 to change
your boot order, if necessary, to make it into the Rescatux menu. The default
option, to find all bootable OSs, will do the trick, so just hit enter and then
choose the first Linux boot option to get back into your typical environment.

### Reinstall GRUB
Since your EFI boot path was wiped by the updater and you probably don't want to
boot via Rescatux forever, once you're back in a sane GNU/Linux environment,
just mount your EFI partition and reinstall GRUB. For me, that process looked
like this.

```bash
$ cfdisk /dev/nvme0n1
$ mount /dev/nvme0n1p1 /boot/efi
$ grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
```

The Intel Management Engine has now been disabled and its code has been removed.
You can try running the firmware updater again, just to be sure that it detects
everything is up to date.

### Cleanup
Finally, feel free to remove `/boot/efi/EFI/system76-firmware-update` and
`/boot/efi/system76-firmware-update`, if they're still around. You can also
remove the GRUB boot entry from `/etc/grub.d/40_custom` and re-generate your
GRUB config.


```bash
$ grub-mkconfig --output /boot/grub/grub.cfg
```


### Post-update issues
In `#system76` on Freenode, which is barren and likely not worth joining, I've
seen some questions about people losing some fn key functionality after the
update. For me, HDMI didn't work at all after the update. I unplugged and
tested the HDMI cable and monitor on another machine and concluded that the
firmware update must've borked something. `xrandr` didn't show any connections,
but I didn't look further into it than that, since it was late and I was pleased
enough to've finished the update.

In the morning, HDMI worked as expected, without any hiccups. Maybe the machine
also just need a good night's rest.
