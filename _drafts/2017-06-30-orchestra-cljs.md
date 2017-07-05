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

### Consideration: Directory structure
For sake of illustration, imagine you're porting a hypothetical `kitty-ninja`
Clojure project to ClojureScript. Your directory structure almost certainly
looks like this:

```text
.
├── project.clj
├── src
│   └── kitty_ninja
│       ├── core.clj
│       └── meow.clj
└── test
    └── kitty_ninja
        ├── core_test.clj
        └── meow_test.clj
```

There are three types of Clojure files to deal with, when supporting both
Clojure and ClojureScript. There's the obvious `clj` and `cljs`, but also
`cljc`, which represents a file which may be compiled as either Clojure or
ClojureScript. When refactoring your shared code from Clojure land to be exposed
to ClojureScript, `cljc` is what will be used. For the most part, code in `cljc`
files can either be Clojure or ClojureScript, but platform-specific bits can
also be included using [reader
conditionals](https://clojure.org/guides/reader_conditionals).

The directory structure is thus changed to something like this:

```text
.
├── project.clj
├── src
│   ├── clj
│   │   └── kitty_ninja
│   │       └── core.clj
│   ├── cljc
│   │   └── kitty_ninja
│   │       └── meow.cljc
│   └── cljs
│       └── kitty_ninja_cljs
│           └── core.cljs
└── test
    ├── clj
    │   └── kitty_ninja
    │       └── core_test.clj
    ├── cljc
    │   └── kitty_ninja
    │       └── meow_test.cljc
    └── cljs
        └── kitty_ninja_cljs
            └── core_test.cljs
```

As is shown, the `meow` functionality is shared between both Clojure and
ClojureScript. Furthermore, its tests are also shared. Aside from that, both
Clojure and ClojureScript have their own platform-specific code and tests/entry
points as well. More on this later.

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
