---
title: The issue of trust on Android
labels: [tutorial]
tags: [security, privacy, android]
---

Trust is a difficult issue when it comes to computing, but the ecosystem
around it is especially bad on mobile. We live our lives within our mobile
phones, but they're also far less under our control than a typical laptop or
desktop. When you install an app, how can you know that it's benign? Furthermore,
when you upgrade it, how can you ensure it remains so? For the vast majority of
people, even technical people, these questions never arise. That alone isn't the
problem though; the real problem is that, when considered, the answers aren't very convincing.

### Google Play
Google Play is the de facto way of installing apps on an Android device. It goes
without saying. However, that convenience comes at a cost. The most obvious is
privacy, but that cost is better understood. Another cost is security, since
you have no way of knowing the intentions of the apps you install through Google
Play. Notoriously, Google is known to allow just about any app onto Google Play,
with minimal review. This has lead to Google Play being a cesspool of malware
and mirror apps, which are design to look like an existing legitimate app, but
are unofficial and entirely untrustworthy.

#### Integrity
If you trust a company, you may feel comfortable installing its apps from the
Play Store. For example, Open Whisper Systems, the company behind
[Signal](https://signal.org/), may hold your regard. However, *whenever you
install anything from Google Play*, you also need to [trust
Google](https://www.expressvpn.com/blog/google-play-targeted-by-nsa/). Even if
the Open Whisper Systems uploads an entirely benign application to Google Play, that doesn't
mean it's what you're downloading. Furthermore, you have absolutely no way of
verifying the app's integrity, given the existing tech built into Android's app
installation flow.

#### Open source
You can find respite in open source apps though, right? Not quite. Even if an
app is open source, you run into the same exact problem when you install it from
Google Play.

*Is the binary derived directly from the source you see, or has it
been modified? What about the updates?*

There are distribution platforms specifically for open source apps, too. The
most popular is, perhaps, F-Droid.  Alas, apps on F-Droid are still distributed
as binaries. Even worse, they're not all signed by the developers, they're
signed by the maintainer of F-Droid.

#### Permissions
### Side-loading
### F-Droid
### Manual build
### iOS
### A path toward reproducibility
### A path toward agency


























* davdroid, icsdroid, etar, signal

### Generate a keystore

```bash
keytool -genkey -v \
        -keystore self-built.keystore -storetype pkcs12 \
        -alias self-built \
        -keyalg RSA -keysize 4096 \
        -validity 365 
```

### Sign the unsigned APK
```bash
jarsigner -verbose \
          -sigalg SHA1withRSA \
          -digestalg SHA1 \
          -keystore self-built.keystore \
          app/build/outputs/apk/standard/release/app-standard-release-unsigned.apk \
          self-built
```
