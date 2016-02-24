---
title: Enable HTTPS for your Github Pages
tags: [ssl, github, pages, https, letsencrypt, simp_le]
---

With the rise of free encryption through [Let's
Encrypt](https://letsencrypt.org/), and the weight of global surveillance on our
minds, adopting HTTPS is now more important than ever. Github now allows
unforced HTTPS for its `username.github.io` domains, but that coverage doesn't
carry over to those using custom domains. The approach I'm using for this blog
and my [home page](https://jeaye.com/), by way of reverse proxy, is documented
herein.

### SSL Certs

Before any HTTPS configuration can be setup, SSL certs are required. I use
[simp_le](https://github.com/kuba/simp_le) and [NixOS](http://nixos.org/)
([related
configs](https://github.com/jeaye/nix-files/blob/master/service/acme.nix)),
which is a Let's Encrypt front-end; there are [many others to
consider](https://www.metachris.com/2015/12/comparison-of-10-acme-lets-encrypt-clients/)
though. Let's assume you're building your new website `honest-kittens.org`. Be
sure to include at least `www.honest-kittens.org` in your certificate as well.

### The Apache proxy

The way to get around Github's lack of SSL support for custom domains is to have
that domain use a proxy server which talks to Github and the client. This isn't
very much work, compared to hosting a complete Jekyll stack, so we still benefit
from Github's convenient hosting. To minimize the scope of this post, I assume
you're familiar with administrating an Apache server.

In the virtual host for `honest-kittens.org`, we can enable the proxy engine
using:

```text
SSLProxyEngine On
ProxyPreserveHost Off
```

This will also ensure that, when talking to Github, the proxy server doesn't use
the `honest-kittens.org` host. If it did, the SSL discussion would fail. To have
Apache relay `honest-kittens.org/` to `username.github.io/`, where `username` is
your username, we setup a proxy pass:

```text
ProxyPass / https://username.github.io/
```

**NOTE:** My placement of trailing slashes is deliberate and extremely
important, as is my usage of **https** vs **http**.

Github's server may, for various reasons, send over a 301 redirect request. With
just this configuration, the request will be proxied and sent directly to the
client, causing them to end up at `username.github.io`. That's no good. We'll
then setup a reverse proxy to ensure such redirect from Github is changed before
it hits the client:

```text
ProxyPassReverse / https://username.github.io/
ProxyPassReverse / http://username.github.io/
```

This covers both the HTTP and HTTPS cases, ensuring that links matching the
above `username.github.io` will be translated into the root level of
`honest-kittens.org`.
