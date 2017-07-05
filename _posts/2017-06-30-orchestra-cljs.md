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
The likely first thought, when looking to port the `kitty-ninja` project to
ClojureScript, would be to also have the ClojureScript counterpart be in the
`kitty-ninja` namespace.

*This will cause much, much more harm than good.*

For this reason, we have `cljs.spec` instead of `clojure.spec` for
ClojureScript. Similarly, we now have `orchestra-cljs.spec.test` instead of
`orchestra.spec.test`. Since ClojureScript can actually require Clojure files,
and all of its macros are run in Clojure, as well as the class path issues that
arise with having `src/clj/` and `src/cljs/` in your Leiningen `:source-paths`,
just agree from the start that your ClojureScript port will be in a different
namespace.

### Pitfall: Macros
In ClojureScript, macro expansion is a very distinct phase of compilation, which
involves running Clojure on the ClojureScript code. As such, macros need to be
in either a `clj` or `cljc` file. Part of refactoring `kitty-ninja`, or any
other project, would involve moving the macros which will be shared with
ClojureScript to the `src/cljc/` directory. Furthermore, any
ClojureScript-specific macros may be kept in the `src/cljs/` directory. This may
be counter-intuitive, since it means there will be `cljc` files in `src/cljs/`,
but this makes sense in the case where they're for ClojureScript-only macros.

There is also a pattern, which has largely gone unstated as far I can tell,
where a `cljs` and `cljc` file can have the same file name and namespace.  If
the `cljs` file requires the `cljc` version, to bring in its macros, then
they'll automatically be available to anyone to requires the `cljs` file. Here's
an illustration of how that works:

```text
.
└── src
    └── cljs
        └── kitty_ninja_cljs
            ├── core.cljs
            ├── stealth.cljc
            └── stealth.cljs
```

**stealth.cljc**:
```clojure
(ns kitty-ninja-cljs.stealth)

(defmacro purr []
  `(println "purrrr"))
```

**stealth.cljs**:
```clojure
(ns kitty-ninja-cljs.stealth
  (:require-macros [kitty-ninja-cljs.stealth :as st]))
```

**core.cljs:**
```clojure
(ns kitty-ninja-cljs.core
  (:require [kitty-ninja-cljs.stealth :as st]))

(st/purr) ; Macro invocation without having to do require-macros
```

### Pitfall: Cljsbuild profiles
Unlike [Leiningen
profiles](https://github.com/technomancy/leiningen/blob/master/doc/PROFILES.md),
which are quite flexible,
[cljsbuild](https://github.com/emezeske/lein-cljsbuild) profiles tend toward
redundancy. Furthermore, cljsbuild requires a top-level key in the
`project.clj`. As a result, the best setup I've found is to provide the base
information at the top-level, using a fixed build name, rather than in a shared
Leiningen profile. From there, use Leiningen profiles to customize the values
you need. Here's an annotated example from Orchestra:

```clojure
(defproject ; ... elided a great deal ...

  ; Keep cljs in here so `lein jar` packages the sources
  :source-paths ["src/clj/" "src/cljs/"]

  ; Base cljs setup
  :cljsbuild {:test-commands {"test" ["lein" "doo" "node" "app" "once"]}
              :builds {:app
                       {:source-paths ["src/cljs/"]
                        :compiler
                        {:optimizations :advanced
                         :pretty-print false
                         :parallel-build true
                         :output-dir "target/test"
                         :output-to "target/test.js"}}}}

  ; Custom dev dependencies, sources, and entry point for test running
  :profiles {:dev {:dependencies [[lein-doo "0.1.7"]]
                   :source-paths ["test/clj/" "test/cljc/"]
                   :cljsbuild {:builds {:app
                                        {:source-paths ["test/cljs/" "test/cljc/"]
                                         :compiler
                                         {:main orchestra-cljs.test
                                          :target :nodejs}}}}}})
```

### Consideration: Tests with doo
A combination of [doo](https://github.com/bensu/doo) and ClojureScript's
`cljs.test` will allow for mostly painless sharing of tests between Clojure and
ClojureScript. A word of caution, however, based on my experience:

*Use Node for your tests, not Phantom.*

There exists an [issue on doo](https://github.com/bensu/doo/issues/135) for
this, but PhantomJS is not as well supported and, in my experience, not nearly
as reliable. Fortunately, switching to Node should be as easy as adding
`:target :nodejs` to the cljsbuild profile and changing the `lein doo` command
to use `node` instead of `phantom`. See the Orchestra profile above for
reference.

### Wrapping up
ClojureScript's tooling doesn't compare to Clojure's, but it's certainly a
capable platform. For those already working in ClojureScript, be it with
React(Native) or anything else, please do consider using spec and
instrumentation to aid in your development. For those coming to ClojureScript,
from Clojure, hopefully these points will save you some time.
