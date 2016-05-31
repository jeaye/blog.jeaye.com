---
title: HTTPS and the illusion of privacy
tags: [http, https, ssl, tls, security]
---

With the rise of per-website encryption, and the
[ease at which it now comes](https://blog.jeaye.com/2016/03/01/github-pages-https/),
we begin to expect new sites, and popular sites, to adopt this added security.
But what does it buy us? Don't be misled into thinking your browsing is private.

<div style="text-align:center">
<a href="{{ site.blog_url }}/img/vim-qt/vim-qt.png" target="_blank">
<img alt="vim-qt default screen shot"
     src="/img/https-illusion/blog-jeaye.png" />
</a>
<br/> <br/>
</div>

Firefox presents this comforting green lock when it's using HTTPS for a web
page. If you take anything away from this, let it be that this does not mean
your browsing is private.

*Security does not mean privacy.*

### What to keep in mind
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

*The green lock doesn't mean you're safe.*

### So, is HTTPS worth it?
[HTTPS](https://en.wikipedia.org/wiki/Https) adds a layer of TLS encryption atop
the age-old HTTP communications we use while browsing. It succeeds in making
[MITM](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) attacks more
difficult and protecting the data in transmission from tampering. Yes, HTTPS is
absolutely worth it.

*Without encryption, all of your web browsing is to be considered public knowledge.*

### What you can do
Most importantly, understand the implications of using a website, HTTPS or
otherwise. To help with using HTTPS more often, consider the
[HTTPS Everywhere](https://www.eff.org/https-everywhere) plugin. You might also
consider [Privacy Badger](https://www.eff.org/privacybadger) and
[μblock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/).

*As soon as that data has been shared, you can never take it back.*

Once you understand that every website you browse through HTTPS still knows who
you are, if you want to make that more difficult, you might consider using an
anonymizer like [Tor](https://www.torproject.org/).

### Why you should care
*"Arguing that you don't care about the right to privacy because you have
nothing to hide is no different than saying you don't care about free speech
because you have nothing to say."* ~[Snowden](https://en.wikipedia.org/wiki/Nothing_to_hide_argument)
