---
title: The power of Clojure's for loop
tags: [clojure, programming, tutorial, review]
---

Higher order functions in Clojure get a great deal of attention, and for good
reason. Clojure has a [rich standard library](http://www.clojureatlas.com/org.clojure:clojure:1.4.0.html) of functions which focus on purely transforming data. Still, for concise list comprehension, it's hard to beat [for](https://www.conj.io/store/v1/org.clojure/clojure/1.8.0/clj/clojure.core/for).

### List comprehension
Many popular languages these days have [list comprehension](https://en.wikipedia.org/wiki/List_comprehension), most of which seem to be [dynamic](https://en.wikipedia.org/wiki/Dynamic_programming_language), and some are even rather [imperative](https://en.wikipedia.org/wiki/Imperative_programming), like Python. Here are some examples of how `for` can be used in Clojure.

#### Map
```clojure

```

#### Filter
```clojure
(for [x {:a 1 "b" 2 :c 3}
      :when (-> x first keyword?)]
  x)
; ([:a 1] [:c 3])
```

#### Extra map values
It's possible to destructure within the bindings of `for`, allowing for easy
access to nested values.

```clojure
(for [[k v] {:a 1 :b 2 :c 3}]
  v)
; (1 2 3)
```
### Worth noting
Lazy!
