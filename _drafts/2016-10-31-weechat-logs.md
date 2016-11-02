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


```text
$ ls -lhS | head
total 2.0G
-rw-rw-r-- 1 irc git 574M Nov  2 12:14 irc.freenode.##news.weechatlog
-rw-rw-r-- 1 irc git 335M Nov  2 12:14 irc.freenode.##programming.weechatlog
-rw-rw-r-- 1 irc git 149M Apr  9  2016 irc.freenode.##c++.weechatlog
-rw-rw-r-- 1 irc git 102M Nov  2 12:20 irc.freenode.##slackware.weechatlog
-rw-rw-r-- 1 irc git  93M Nov  2 12:22 irc.freenode.#clojure.weechatlog
-rw-rw-r-- 1 irc git  78M Nov  2 12:26 irc.freenode.#osdev.weechatlog
-rw-rw-r-- 1 irc git  59M Apr  9  2016 irc.freenode.##opengl.weechatlog
-rw-rw-r-- 1 irc git  52M Nov  2 12:26 irc.freenode.#nixos.weechatlog
-rw-rw-r-- 1 irc git  52M Apr  8  2016 irc.freenode.#lisp.weechatlog
-rw-rw-r-- 1 irc git  51M Apr  9  2016 irc.freenode.##c++-general.weechatlog
```