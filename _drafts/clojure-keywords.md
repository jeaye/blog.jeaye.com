---
title: The five common forms of Clojure keywords
labels: [clojure, tutorial]
tags: [clojure, keyword]
---

Depending on what libraries are being used, Clojure has a handful of various
different idiomatic forms keywords can take. When approaching some forms, like
those in [Datomic](http://www.datomic.com/), the overall intention may not be
immediately clear. For a new Clojure developer, it may also be unclear which
form should be the default, and why. This post aims to add some clarity to the
subject and applies to both Clojure and ClojureScript. Along with explanations
of each keyword form is a recommendation for when to use it and when to opt for
another.

### Brief: the five common forms
1. `:foo`, which is just your plain old keyword
2. `::foo`, which is a namespaced keyword for the current namespace
3. :my.ns/name, which is a namespaced keyword for a valid ns
4. ::my/name, which uses the :as alias to achieve the same as point 3
5. :something/foo, which is commonly used with Datomic and doesn't actually map to a valid ns

### Plain old keywords
These will show up most often in Clojure and ClojureScript available on the web.
They're easy to type, they don't require any dependencies, and they make it easy
for anyone to consume. That convenience, however, comes at a cost; they can
easily cause name collisions, they don't convey ownership, and, for those
reasons, they can't be used for `clojure.spec`.

**Recommendation:** Avoid plain old keywords by default. If you have a map of
data being passed around, for example, namespace the keywords (and consider
adding specs for the data). If you have an "enum," meaning one in a discrete set
of possible keywords, also namespace them. The only time when a plain old
keyword's convenience overcomes its cost is within a simple API with no
middleware, so no possibility for collisions. An example of this would be
`(clojure.data.json/read-str "{}" :key-fn keyword)`.

### TODO
specific cases like honeysql

https://www.deepbluelambda.org/programming/clojure/know-your-keywords
