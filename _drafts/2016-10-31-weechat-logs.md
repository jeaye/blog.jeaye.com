---
title: Optimizing weechat log usage
tags: [tutorial, weechat, log, linux]
---

weechat is a curses-based IRC client and a very sane alternative to irssi. For
those with [IRC bouncers](https://en.wikipedia.org/wiki/BNC_%28software%29), or
those who spend a great deal of time on IRC, popular channels can start to
accrue rather large logs. By default, those logs are quite verbose and are never
rotated. In my case, my logs were taking up 2GB worth of disk space on my VPS.

#### Investigating the issue
My first question, when my monitoring showed that disk usage had passed the 90%
mark, is "what's growing and can it be trimmed?" After using
[du](https://linux.die.net/man/1/du) to find which user directories were the
issue, I was able to pinpoint a couple of culprits. The biggest one was weechat.
```text
$ du -h -d1 ~
... elided ...
2.0G    ~/.weechat
... elided ...
```

It makes sense that weechat's logs would be large, since it's constantly running
on this machine. Still, my next question was "which channels are taking up the
most space?"

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

Much to my initial surprise, the ##news channel log was significantly larger
than anything else. The freenode ##news channel contains various bots for
sharing links to news as it comes out. In fact, it's not actually something I
care to log, since it's just links to news articles.

#### Asking weechat to ignore certain buffers
Given that the ##news channel logs aren't going to be useful to me, I then
looked to disable logging on that channel entirely.

```bash
/set logger.level.irc.freenode.##news 0
```
