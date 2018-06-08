---
title: Building your Android apps from source
labels: [tutorial]
tags: [security, privacy, android]
---

keytool -genkey -v \
        -keystore self-built.keystore -storetype pkcs12 \
        -alias self-built \
        -keyalg RSA -keysize 4096 \
        -validity 365 

jarsigner -verbose \
          -sigalg SHA1withRSA \
          -digestalg SHA1 \
          -keystore self-built.keystore \
          app/build/outputs/apk/standard/release/app-standard-release-unsigned.apk \
          self-built
