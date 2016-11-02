---
title: Optimizing weechat log usage
tags: [tutorial, weechat, log, linux]
---

weechat is a curses-based IRC client and a very sane alternative to irssi. For
those with [IRC bouncers](https://en.wikipedia.org/wiki/BNC_%28software%29), or
those who spend a great deal of time on IRC, popular channels can start to
accrue rather large logs. By default, those logs are quite verbose and are never
rotated. In my case, my logs were taking up 2GB worth of disk space on my VPS.

```text
$ du -h -d1 ~
... elided ...
2.0G    ~/.weechat
... elided ...
```
