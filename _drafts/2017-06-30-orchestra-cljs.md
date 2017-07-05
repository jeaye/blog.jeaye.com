---
title: Porting Orchestra to ClojureScript
tags: [clojure, clojurescript, spec, orchestra, dependent types, safety]
---

[Orchestra](https://github.com/jeaye/orchestra) is a Clojure library made as a
drop-in replacement for `clojure.spec.test.alpha`, which provides custom
instrumentation that validates all aspects of function specs. Now, it also works
with ClojureScript. This post covers some pitfalls of porting Clojure projects
to ClojureScript, as well as some instruction for those looking to do so while
maintaining a respectable amount of sanity.

namespaces must be different (a la cljs.spec)
macros need to be in cljc files
cljsbuild profiles are limiting
tests with doo
phantom => node (link to issue of phantom dying)
