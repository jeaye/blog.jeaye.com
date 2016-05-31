---
title: HTTPS and the illusion of privacy
tags: [http, https, ssl, tls, security]
---

With the rise of per-website encryption, and the
[ease at which it now comes](https://blog.jeaye.com/2016/03/01/github-pages-https/),
we begin to expect new sites, and popular sites, to adopt this added security.
But what does it buy us? Don't be misled into thinking your browsing is private.

### HTTPS
[HTTPS](https://en.wikipedia.org/wiki/Https) adds a layer of TLS encryption atop
the age-old HTTP communications we use while browsing. It succeeds in making
[MITM](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) attacks more
difficult and protecting the data in transmission from tampering.

Without encryption, all of your web browsing is to be considered public knowledge.


### Shortcomings
When browsing a website which uses HTTPS, anyone viewing your traffic (such as
your ISP, someone on your network, or even other processes on your computer)
will be able to tell not only which website you're viewing, but for how long and
how frequently. Though the content between you and the website is encrypted, the
fact that you're connected to the website's IP is to be considered public
knowledge.

Furthermore, even if a website is using HTTPS, by using it, you give it your
absolute trust. For example, your favorite search engine likely forces HTTPS.
That's good, since it makes it difficult for others to sniff out what you're
searching, even though they can tell that you're searching. Alas, it doesn't
change the fact that your favorite search engine knows exactly what you
searched. What it does with that data would then be entirely out of your hands.

![blog.jeaye.com](/img/https-illusion/blog-jeaye.png)

Firefox presents this comforting green lock when it's using HTTPS for a web
page. If you take anything away from this, let it be that *this does not mean
your browsing is private.*

use https everywhere (plugin)
privacy badger
ublock origin
