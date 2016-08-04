---
title: Practical Onyx: from shell to distributed computing
tags: [clojure, programming, tutorial, onyx, distributed]
---

### Setup basic project

```bash
$ lein new app toy-server
$ cd toy-server
$ lein run # should see "Hello, World!"
```

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

project.clj
```clojure
:repositories {"my.datomic.com" {:url "https://my.datomic.com/repo"
                                 :creds :gpg}}
:dependencies [[com.datomic/datomic-pro "0.9.5385"]]
```

Download the new deps
```bash
$ lein deps # enter GPG passphrase for datomic
```

Test out an in-memory db:
```clojure
(ns toy-server.core
  (:gen-class)
  (:require [datomic.api :as d]))

(def db-uri "datomic:mem://toy-server")
(d/create-database db-uri)
(def conn (d/connect db-uri))
(def db (d/db conn))
(def datom [:db/add (d/tempid :db.part/user)
            :db/doc "hello world"])

(defn -main
  [& args]
  @(d/transact conn [datom])
  (println (d/q '[:find ?e :where [?e :db/doc "hello world"]] db)))
```

### Resources
#### Videos
https://www.infoq.com/presentations/Thinking-in-Data
http://www.flyingmachinestudios.com/programming/building-a-forum-with-clojure-datomic-angular/
