---
title: Running Xen on Slackware 14.1 with GCC 5.1
tags: [linux, slackware, xen]
---

#### Preface
My Slackware setup is unique, since, unlike most Slackers, I've compiled my entire OS from source. I require the latest GCC 5.1, for work with C++14, the latest Vim, for use of [color_coded](https://github.com/jeaye/color_coded), and the ABI incompatibilities that follow have led me down a winding path.

#### How
When I wanted to do some virtualization with VGA pass-through, I found myself compiling Xen and running into some nasty issues. To do the heavy lifting, I used [sbopkg](http://sbopkg.org/). In order to patch the Slackbuild it uses, I copied `xen.Slackbuild` to `xen.Slackbuild.sbopkg` in `/var/lib/sbopkg/SBo/14.1/system/xen`. Once such a file exists, sbopkg will prompt me to use it while compiling.

The first issue was as follows:

```text
symbols.c:23:61: error: array subscript is above array bounds [-Werror=array-bounds]
#define symbols_address(n) (SYMBOLS_ORIGIN + symbols_offsets[n])
```

Which, as I found in the [AUR comments](https://aur.archlinux.org/packages/xen/?comments=all), was solved with a quick patch (`patches/subscript.patch`):

```diff
--- a/xen/common/symbols.c.orig	2015-01-12 17:53:24.000000000 +0100
+++ b/xen/common/symbols.c	2015-05-24 18:47:56.186578687 +0200
@@ -19,7 +19,7 @@
 #include <xen/spinlock.h>
 
 #ifdef SYMBOLS_ORIGIN
-extern const unsigned int symbols_offsets[1];
+extern const unsigned int symbols_offsets[];
 #define symbols_address(n) (SYMBOLS_ORIGIN + symbols_offsets[n])
 #else
 extern const unsigned long symbols_addresses[];
```

The next issues I saw were some unresolved linker symbols.

```text
undefined reference to `usb_kbd_command'
undefined reference to `usb_mouse_command'
```

The patch is as follows (`patches/stack.patch`):

```diff
--- a/tools/firmware/seabios-dir-remote/src/kbd.c
+++ b/tools/firmware/seabios-dir-remote/src/kbd.c
@@ -11,7 +11,7 @@
 #include "hw/ps2port.h" // ps2_kbd_command
 #include "hw/usb-hid.h" // usb_kbd_command
 #include "output.h" // debug_enter
-#include "stacks.h" // stack_hop
+#include "stacks.h" // yield
 #include "string.h" // memset
 #include "util.h" // kbd_init
 
@@ -117,8 +117,8 @@ static int
 kbd_command(int command, u8 *param)
 {
     if (usb_kbd_active())
-        return stack_hop(command, (u32)param, usb_kbd_command);
-    return stack_hop(command, (u32)param, ps2_kbd_command);
+        return usb_kbd_command(command, param);
+    return ps2_kbd_command(command, param);
 }
 
 // read keyboard input
diff --git a/src/mouse.c b/src/mouse.c
index 83e499d..6d1f5b7 100644
--- a/tools/firmware/seabios-dir-remote/src/mouse.c
+++ b/tools/firmware/seabios-dir-remote/src/mouse.c
@@ -10,7 +10,7 @@
 #include "hw/ps2port.h" // ps2_mouse_command
 #include "hw/usb-hid.h" // usb_mouse_command
 #include "output.h" // dprintf
-#include "stacks.h" // stack_hop
+#include "stacks.h" // stack_hop_back
 #include "util.h" // mouse_init
 
 void
@@ -27,8 +27,8 @@ static int
 mouse_command(int command, u8 *param)
 {
     if (usb_mouse_active())
-        return stack_hop(command, (u32)param, usb_mouse_command);
-    return stack_hop(command, (u32)param, ps2_mouse_command);
+        return usb_mouse_command(command, param);
+    return ps2_mouse_command(command, param);
 }
 
 #define RET_SUCCESS      0x00

--
```

Lastly, I ran into a few similar issues which have also shown up in other projects. These issues are related to GCC 5.1 being more strict than previous versions and the solutions are generally quite simple. The errors will manifest as:

```text
drivers/net/ath/ath9k/ath9k_ar9003_phy.c: In function 'ar9003_hw_ani_control':
drivers/net/ath/ath9k/ath9k_ar9003_phy.c:862:11: error: logical not is only applied to the left hand side of comparison [-Werror=logical-not-parentheses]
   if (!on != aniState->ofdmWeakSigDetectOff) {
           ^
drivers/net/ath/ath9k/ath9k_ar9003_phy.c:1016:14: error: logical not is only applied to the left hand side of comparison [-Werror=logical-not-parentheses]
   if (!is_on != aniState->mrcCCKOff) {
```

There are two files which need to be patched, as shown below:

`patches/ath9k.patch`

```diff
--- tools/firmware/etherboot/ipxe/src/drivers/net/ath/ath9k/ath9k_ar9003_phy.c  2015-06-21 22:01:02.701058530 +0800
+++ tools/firmware/etherboot/ipxe/src/drivers/net/ath/ath9k/ath9k_ar9003_phy.c  2015-06-21 22:01:27.499057064 +0800
@@ -859,7 +859,7 @@
                        REG_CLR_BIT(ah, AR_PHY_SFCORR_LOW,
                                    AR_PHY_SFCORR_LOW_USE_SELF_CORR_LOW);

-               if (!on != aniState->ofdmWeakSigDetectOff) {
+               if ((!on) != aniState->ofdmWeakSigDetectOff) {
                        DBG2("ath9k: "
                                "** ch %d: ofdm weak signal: %s=>%s\n",
                                chan->channel,
@@ -1013,7 +1013,7 @@
                              AR_PHY_MRC_CCK_ENABLE, is_on);
                REG_RMW_FIELD(ah, AR_PHY_MRC_CCK_CTRL,
                              AR_PHY_MRC_CCK_MUX_REG, is_on);
-               if (!is_on != aniState->mrcCCKOff) {
+               if ((!is_on) != aniState->mrcCCKOff) {
                        DBG2("ath9k: "
                                "** ch %d: MRC CCK: %s=>%s\n",
                                chan->channel,
```

`patches/ath9k2.patch`

```diff
--- tools/firmware/etherboot/ipxe/src/drivers/net/ath/ath9k/ath9k_ar5008_phy.c.orig     2011-12-11 03:28:04.000000000 +0100
+++ tools/firmware/etherboot/ipxe/src/drivers/net/ath/ath9k/ath9k_ar5008_phy.c  2015-05-25 11:14:30.732759966 +0200
@@ -1141,7 +1141,7 @@
                        REG_CLR_BIT(ah, AR_PHY_SFCORR_LOW,
                                    AR_PHY_SFCORR_LOW_USE_SELF_CORR_LOW);

-               if (!on != aniState->ofdmWeakSigDetectOff) {
+               if ((!on) != aniState->ofdmWeakSigDetectOff) {
                        if (on)
                                ah->stats.ast_ani_ofdmon++;
                        else
@@ -1307,7 +1307,7 @@
                        REG_CLR_BIT(ah, AR_PHY_SFCORR_LOW,
                                    AR_PHY_SFCORR_LOW_USE_SELF_CORR_LOW);

-               if (!on != aniState->ofdmWeakSigDetectOff) {
+               if ((!on) != aniState->ofdmWeakSigDetectOff) {
                        DBG2("ath9k: "
                                "** ch %d: ofdm weak signal: %s=>%s\n",
                                chan->channel,
```

#### Bringing it together
Given these patches, the only task remaining was to tie them together into a working Slackbuild script. Since some sources are only extracted once one tries to build them, the tools need to be built in two steps: try first, patch, then try again. Such is life (and my impatience).

I found that there were some issues with the existing Slackbuild, as it was using incorrect paths during install (see the diff below). Also, I've had no issues adding `-j8` to each of these `make` commands, which has made my life much easier.

The resulting `xen.Slackbuild.sbopkg` patch:

```diff
--- xen.SlackBuild.sbopkg.orig	2015-06-21 23:32:03.247735702 +0800
+++ xen.SlackBuild.sbopkg	2015-06-21 23:29:54.094743338 +0800
@@ -132,21 +132,36 @@
   --docdir=/usr/doc/$PRGNAM-$VERSION \
   --build=$ARCH-slackware-linux
 
-make install-xen \
+# XXX: Add GCC5 support
+patch -p1 <$CWD/patches/stack.patch
+patch -p1 <$CWD/patches/subscript.patch
+
+make -j8 install-xen \
   docdir=/usr/doc/$PRGNAM-$VERSION \
   DOCDIR=/usr/doc/$PRGNAM-$VERSION \
   mandir=/usr/man \
   MANDIR=/usr/man \
   DESTDIR=$PKG
 
-make install-tools \
+make -j8 install-tools \
   docdir=/usr/doc/$PRGNAM-$VERSION \
   DOCDIR=/usr/doc/$PRGNAM-$VERSION \
   mandir=/usr/man \
   MANDIR=/usr/man \
-  DESTDIR=$PKG
+  DESTDIR=$PKG || true
+
+# XXX: Try again
+patch -p0 <$CWD/patches/ath9k.patch
+patch -p0 <$CWD/patches/ath9k2.patch
+
+make -j8 install-tools \
+  docdir=/usr/doc/$PRGNAM-$VERSION \
+  DOCDIR=/usr/doc/$PRGNAM-$VERSION \
+  mandir=/usr/man \
+  MANDIR=/usr/man \
+  DESTDIR=$PKG || true
 
-make install-stubdom \
+make -j8 install-stubdom \
   docdir=/usr/doc/$PRGNAM-$VERSION \
   DOCDIR=/usr/doc/$PRGNAM-$VERSION \
   mandir=/usr/man \
@@ -163,17 +178,18 @@
 # Remove useless symlinks in boot/
 find $PKG/boot/ -type l -a -name "xen-*" -exec rm -f {} \; 2>/dev/null || true
 
-# Move from SYSV to BSD init scripts
-mv $PKG/etc/rc.d/init.d/xen-watchdog $PKG/etc/rc.d/rc.xen-watchdog.new
-mv $PKG/etc/rc.d/init.d/xencommons $PKG/etc/rc.d/rc.xencommons.new
-mv $PKG/etc/rc.d/init.d/xendomains $PKG/etc/rc.d/rc.xendomains.new
+# Move from SYSV to BSD init scripts XXX
+mkdir -p $PKG/etc/rc.d
+mv $PKG/etc/init.d/xen-watchdog $PKG/etc/rc.d/rc.xen-watchdog.new
+mv $PKG/etc/init.d/xencommons $PKG/etc/rc.d/rc.xencommons.new
+mv $PKG/etc/init.d/xendomains $PKG/etc/rc.d/rc.xendomains.new
 
 # Put udev rules files in the right place
 mkdir -p $PKG/lib/udev/rules.d
 mv $PKG/etc/udev/rules.d/xen*.rules $PKG/lib/udev/rules.d/
 
 # Remove empty directories
-rmdir $PKG/etc/{rc.d/init.d,udev/rules.d,udev}
+rmdir $PKG/etc/{init.d,udev/rules.d,udev}
 
 # Append .new to config files
 for i in $PKG/etc/xen/*.conf ; do mv $i $i.new ; done
```

Now that Xen is installed, getting my spare nVidia (GeForce 670MX) card to work with pass-through VGA on a running Dom0 is likely to prove much more challenging.
