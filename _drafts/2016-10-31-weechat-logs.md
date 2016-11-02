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
/save
```

From there, I was safe to delete the ##news weechat log. That brought the disk
usage down to 1.4G already.

#### Choosing what you log
After inspecting the documentation for weechat's logger plugin, `/help logger`,
I saw that the default logging level for each channel is `9`. Here's a breakdown
of the levels, from the documentation:

```text
1: user message, notice, private
2: nick change
3: server message
4: join/part/quit
9: all other messages
```

In my logs, I don't care about join/part/quit events, and whatever other
messages there may be; dropping the level down to 3 for every channel seems
perfectly reasonable.

```text
/set logger.level.irc 3
```

#### Cleaning up existing logs
Once weechat was logging more minimally, and not logging specific channels,
there was still the issue of 1.4GB worth of logs, all of which had been formed
using weechat's level `9` setting. So I investigated how much that difference
actually was, knowing that my `weechat.look.prefix_join` was `»»»` and my
`weechat.look.prefix_quit` was `«««`.

```text
# Total size of the largest log (335MB)
$ wc -c irc.freenode.##programming.weechatlog
350526327 irc.freenode.##programming.weechatlog

# Total number of joins/parts/quits in that file (1.3 million)
$ egrep -c "»»»|«««" irc.freenode.##programming.weechatlog
1363355

# Total size of the log without those joins/parts/quits (208MB)
$ wc -c <(sed '/»»»\|«««/d' irc.freenode.##programming.weechatlog)
208668563 /dev/fd/63
```

Alright! I could trim off 97MB from my largest buffer, just by removing the
joins/parts/quits. Even better, some channels have a much higher join/part/quit
to message ratio.

```bash
# This may take a few moments
for log in *.weechatlog; do sed -i '/»»»\|«««/d' "$log"; done
```

And now for the final numbers:

```text
$ ls -lhS | head
total 721M
-rw-rw-r-- 1 irc git  200M Nov  2 13:05 irc.freenode.##programming.weechatlog
-rw-rw-r-- 1 irc git   71M Nov  2 13:05 irc.freenode.##slackware.weechatlog
-rw-rw-r-- 1 irc git   49M Nov  2 13:05 irc.freenode.#osdev.weechatlog
-rw-rw-r-- 1 irc git   47M Nov  2 13:05 irc.freenode.##c++.weechatlog
-rw-rw-r-- 1 irc git   34M Nov  2 13:05 irc.freenode.#osdev-offtopic.weechatlog
-rw-rw-r-- 1 irc git   30M Nov  2 13:05 irc.freenode.#nixos.weechatlog
-rw-rw-r-- 1 irc git   26M Nov  2 13:05 irc.freenode.##c++-social.weechatlog
-rw-rw-r-- 1 irc git   24M Nov  2 13:05 irc.freenode.##opengl.weechatlog
-rw-rw-r-- 1 irc git   24M Nov  2 13:05 irc.freenode.##csharp.weechatlog
```

Removing the join/part/quit events cut the total log size in half, from 1.4GB to
720MB. As far as I'm concerned, the useful content is still there.

#### Compressing, rotating, and next steps
This setup could be further improved by
[rotating](https://en.wikipedia.org/wiki/Log_rotation) large logs and
compressing non-active logs. Out of the box, this would impede on the ability to
use those logs within weechat, via
[grep.py](https://weechat.org/scripts/source/grep.py.html/) or similar. I found
an [open issue](https://github.com/weechat/weechat/issues/314) on weechat's
Github that requests for gzip functionality. Hopefully something like this could
be officially supported.

In the meantime, for those looking to use
[logrotate](https://linux.die.net/man/8/logrotate), Jelle van der Waa has a
write up about [how to do so with
weechat](http://vdwaa.nl/archlinux/systemd/weechat/logs/logrotate-weechat-logs/).
