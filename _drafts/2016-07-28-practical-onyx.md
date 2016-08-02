---
title: Practical Onyx: from shell to distributed computing
tags: [clojure, programming, tutorial, onyx, distributed]
---

### Get Datomic

Go here; create account; download latest
https://my.datomic.com/starter

Go here; get credentials and write to
https://my.datomic.com/account

~/.lein/credentials.clj
```clojure
{#"my\.datomic\.com" {:username "foo@bar.com"
                      :password "8da1d811-155d-0ee1-3fca-60ec11cfbccbaf"}}
```

```bash
$ gpg --default-recipient-self -e ~/.lein/credentials.clj > ~/.lein/credentials.clj.gpg
```
