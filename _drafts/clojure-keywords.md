---
title: The five common forms of Clojure keywords
tags: [clojure, keyword, tutorial]
---

Depending on what libraries are being used, Clojure has a handful of various
different idiomatic forms keywords can take. When approaching some forms, like
those in [Datomic](http://www.datomic.com/), the overall intention may not be
immediately clear. For a new Clojure developer, it may also be unclear which
form should be the default, and why. This post aims to add some clarity on the
subject.

### Brief: the five forms
1. `:foo`, which is just your typical keyword
2. `::foo`, which is a namespaced keyword for the current namespace;
3. 3. :my.ns/name, which is a namespaced keyword for a valid ns
4. ::my/name, which uses the :as alias to achieve the same as point 3
5. :something/foo, which is commonly shown with Datomic and doesn't actually map to a valid ns

specific cases like honeysql

https://www.deepbluelambda.org/programming/clojure/know-your-keywords
