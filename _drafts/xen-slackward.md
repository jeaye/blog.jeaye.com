---
title: Running Xen on Slackware 14.1 with GCC 5.1
tags: [linux, slackware, xen]
---

## Preface
My Slackware setup is unique, since, unlike most Slackers, I've compiled my entire OS from source. The reason I'd put myself through this is not only my love for Slackware, but also my need for GCC 5.1, which is not part of Slackware 14.1. Due to the ABI changes in the newer GCC, as well as many other changes, the existing Slackbuilds may not compile and may not work with the stock Slackware setup. As a result, I need to manually patch many packages.

## How
When I wanted to do some virtualization with VGA pass-through, I found myself compiling Xen and running into some nasty issues. To do the heavy lifting, I use [sbopkg](http://sbopkg.org/). In order to patch the Slackbuild it uses, I copy `/var/lib/sbopkg/SBo/14.1/system/xen/xen.Slackbuild` to ` /var/lib/sbopkg/SBo/14.1/system/xen/xen.Slackbuild.sbopkg`. Once such a file exists, sbopkg will prompt me to use it while compiling.

The first issue was as follows:
```text
symbols.c:23:61: error: array subscript is above array bounds [-Werror=array-bounds]
#define symbols_address(n) (SYMBOLS_ORIGIN + symbols_offsets[n])
```

Which, as I found in the [AUR comments](https://aur.archlinux.org/packages/xen/?comments=all), is solved with a quick patch (`patches/subscript.patch`):

```patch
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
```patch
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
```patch
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
```patch
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

## Bringing it together
Given these patches, the only task remaining was to tie them together into a working Slackbuild script. Since some sources are only extracted once one tries to build them, the tools need to be built in two steps: try first, patch, then try again. Such is life (and my impatience).

The resulting `xen.Slackbuild.sbopkg` patch:
```patch
--- xen.SlackBuild	2015-03-22 16:38:08.000000000 +0800
+++ xen.SlackBuild.sbopkg	2015-06-21 22:20:12.391990560 +0800
@@ -132,6 +132,10 @@
   --docdir=/usr/doc/$PRGNAM-$VERSION \
   --build=$ARCH-slackware-linux
 
+# XXX: Add GCC5 support
+patch -p1 <$CWD/patches/stack.patch
+patch -p1 <$CWD/patches/subscript.patch
+
 make install-xen \
   docdir=/usr/doc/$PRGNAM-$VERSION \
   DOCDIR=/usr/doc/$PRGNAM-$VERSION \
@@ -144,7 +148,18 @@
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
+make install-tools \
+  docdir=/usr/doc/$PRGNAM-$VERSION \
+  DOCDIR=/usr/doc/$PRGNAM-$VERSION \
+  mandir=/usr/man \
+  MANDIR=/usr/man \
+  DESTDIR=$PKG || true
 
 make install-stubdom \
   docdir=/usr/doc/$PRGNAM-$VERSION \
```

For those without `texinfo` installed, the following will error (my suggestion is to just install texinfo):

```patch
WARNING: `makeinfo' is missing on your system.  You should only need it if
         you modified a `.texi' or `.texinfo' file, or any other file
         indirectly affecting the aspect of the manual.  The spurious
         call might also be the consequence of using a buggy `make' (AIX,
         DU, IRIX).  You might want to install the `Texinfo' package or
         the `GNU make' package.  Grab either from any GNU archive site.
```

Now that Xen is installed, getting my spare nVidia (GeForce 670MX) card to work with pass-through VGA on a running Dom0 is likely to prove much more challenging.
