---
title: The five common forms of Clojure keywords
labels: [clojure, tutorial]
tags: [clojure, keyword]
---

Depending on which libraries are being used, Clojure has a handful of various
idiomatic forms keywords can take. When approaching some forms, like
those in [Datomic](http://www.datomic.com/), the overall intention may not be
immediately clear. For a new Clojure developer, it may also be unclear which
form should be the default, and why. This post aims to add some clarity to the
subject and it applies to both Clojure and ClojureScript. Along with
explanations of each keyword form is a recommendation for when to use it and
when to opt for something else.

### Brief: the five common forms
1. `:foo`, which is just your plain old keyword
2. `::foo`, which is a namespaced keyword for the current namespace
3. `:my.ns/name`, which is a namespaced keyword for a valid namespace
4. `::my/name`, which uses the `:as` alias to achieve the same as point #3
5. `:something/foo`, which is commonly used with Datomic and doesn't actually map to a valid namespace

### Plain old keywords
These will show up most often in the Clojure and ClojureScript available on the
web.  They're easy to type, they don't require any dependencies, and they make
it easy for anyone to consume. That convenience, however, comes at a cost; they
can easily cause name collisions, they don't convey ownership, and, for those
reasons, they can't be used to name specs with `clojure.spec`.

**Recommendation:** Avoid plain old keywords by default. If you have a map of
data being passed around, for example, namespace the keywords (and consider
adding specs for the data). If you have an "enum," meaning one in a discrete set
of possible keywords, also namespace them. The only time when a plain old
keyword's convenience overcomes its cost is within a simple API with no
middleware, so no possibility for collisions. An example of this would be:


```clojure
(clojure.data.json/read-str "{}" :key-fn keyword)
````

### Namespaced keywords
This applies to points #2, #3, and #4 specifically. These are necessary for
specs. They convey ownership, since they're tied to a valid namespace, they
completely avoid the issue of name collision, and they can help explicitly spell
out dependencies. Though they may feel like extra work, since you will need to
treat them as dependencies, I think that willy-nilly access to data is not a
good thing and being explicit about ownership is.

**Recommendation:** Forms #2 and #4 should be your default. Within a namespace,
`::foo` is only one more character than `:foo`, but it contains significantly
more data. When you want to access some other system's data from your app state,
for example, you have a dependency on that data. Tying that dependency on a
namespace level, through a `(:require [my.ns :as my-ns])` allows you to then use
the shorthand #4 form `::my-ns/foo`. If you detect cyclical dependencies and
can't reorganize, or you need to avoid the require for another reason, then the
#3 form can be used. Similarly, within your `config.edn`, you'll use form #3,
since you likely have no requires.

### Grouped keywords
Syntactically, grouped keywords (my own terminology) are namespaced keywords,
but they're not tied to a valid namespace. Instead, the namespace segment is
used for some logical grouping. Datomic uses this for grouping attributes, like
`:db/id` and `:user/name`. You can distinguish this form #5 usage from form #3,
since the namespace portion for form #5 will usually only be a single segment.
That's not guaranteed, however, since `:ninja.kitten/milk` is entirely valid,
even if the namespace `ninja.kitten` doesn't exist.

**Recommendation:** Avoid these in most situations, but use them where
idiomatic. Given that you may want specs for these keywords anyway, I would
recommend replacing `:db/id` with `::db/id` and building a `my-app.db` namespace
with the correct specs; use your own good judgement.

### Dotted keywords
Finally, some Clojure libraries allow, or encourage, the use of dotted keywords
(my own terminology) for string building. It's somewhat more convenient than
using strings, since keywords just have a prefix and needn't be enclosed in
quotes. These forms aren't necessarily recommended, but, within a DSL, it's
often quite clear what the intent is.

#### Example: HoneySQL
[![Clojars Project](https://img.shields.io/clojars/v/honeysql.svg)](https://clojars.org/honeysql)
HoneySQL is an excellent query builder for numerous SQL databases.

```clojure
; Keywords like :f.a are used for string building.
(-> {:select [:a :b :c]
     :from [:foo]
     :where [:= :f.a "baz"]}
    sql/format)
=> ["SELECT a, b, c FROM foo WHERE f.a = ?" "baz"]

; Keywords are also used with symbols to convey operations.
(-> (select :*)
    (from :foo)
    (where [:= :a 1] [:< :b 100])
    sql/format)
=> ["SELECT * FROM foo WHERE (a = ? AND b < ?)" 1 100]
```

#### Example: cljs-oops
[![Clojars Project](https://img.shields.io/clojars/v/binaryage/oops.svg)](https://clojars.org/binaryage/oops)
cljs-oops is an essential library for any ClojureScript being compiled with
`:advanced` optimizations.

```clojure
; Keywords can be used for accessing members of JS objects.
(oget my-js-obj :my-member)

; Nested members can be accessed using dotted keywords.
(oget my-js-obj :transform.position.x)

; Calling functions is much the same.
(ocall js/Math :abs my-debt)
```
