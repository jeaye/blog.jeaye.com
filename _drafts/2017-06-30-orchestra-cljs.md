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

### Pitfall: Namespaces
The likely first thought to a dev looking to port a hypothetical `kitty-ninja`
Clojure project to ClojureScript would be to also have the ClojureScript
counterpart be in the `kitty-ninja` namespace.

*This will cause much, much more harm than good.*

For this reason, we have `cljs.spec` instead of `clojure.spec` for
ClojureScript. Similarly, we now have `orchestra-cljs.spec.test` instead of
`orchestra.spec.test`. Since ClojureScript can actually require Clojure files,
and all of its macros are run in Clojure, as well as the class path issues that
arise with having `src/clj/` and `src/cljs/` in your Leiningen `:source-paths`,
just agree from the start that your ClojureScript port will be in a different
namespace.

project organization
namespaces must be different (a la cljs.spec)
macros need to be in cljc files
cljsbuild profiles are limiting
tests with doo
phantom => node (link to issue of phantom dying)
