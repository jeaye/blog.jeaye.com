---
title: The state of code quality tools in Clojure 1.9
tags: [clojure, spec, orchestra, rant, safety]
---

There are several libraries for verifying code quality in Clojure projects. When
surveying how they'll work on a distributed Clojure server built for Heroku +
Postgres, I took some notes on the issues that came up. These should represent
the current state of things, as well as how we, the Clojure community, can help
improve things.

Out of the nine libraries used, only three of them worked, and only two were
immediately useful for CI. Here are some notes on each. It's worth noting that
the codebase being tested is nothing special, in terms of features used, but
it contains cljc files shared between Clojure and ClojureScript and it makes
heavy use of spec and namespace-qualified keywords. Apparently this causes a lot
of issues with tooling.

### [eastwood](https://github.com/jonase/eastwood) [maintained | doesn't work]
```clojure
[jonase/eastwood "0.2.4"]
```

Eastwood is a great looking linter for Clojure, but it's unable to run on the
server code, since it doesn't support namespaced maps. In the namespaces where
it does run, it raises the same false positive over and over.

#### Relevant tickets
* Namespaced maps: https://github.com/jonase/eastwood/issues/201
* False positives: https://github.com/jonase/eastwood/issues/227

### [yagni](https://github.com/venantius/yagni) [unmaintained | doesn't work]
```clojure
[venantius/yagni "0.1.4"]
```

yagni is an acronym for [You Aren't Gonna Need
It](https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it) and the library is
a dead code finder (the only one of its kind, in the Clojure world).
Unfortunately, it doesn't support reader conditionals and it also chokes on the
usage of spec.

#### Relevant tickets
* Reader conditionals: https://github.com/venantius/yagni/issues/37
* Spec usage: https://github.com/venantius/yagni/issues/36

### [kibit](https://github.com/jonase/kibit) [maintained | doesn't work]
```clojure
[lein-kibit "0.1.5"]
```

kibit is an analyzer which uses core.logic to search for patterns in code
which can be written to be more idiomatic. Like many other such tools, kibit
struggles with parsing some Clojure, like nested requires and reader
conditionals.

#### Relevant tickets
* Nested requires: https://github.com/jonase/kibit/issues/202
* Reader conditionals: https://github.com/jonase/kibit/pull/194

### [lein-bikeshed](https://github.com/dakrone/lein-bikeshed) [maintained | works]
```clojure
[lein-bikeshed "0.4.1"]
```

lein-bikeshed is one of the tools which worked out of the box. Unfortunately,
the output wasn't terribly useful. The two issues reported were some lines
longer than 80 characters and some functions missing doc strings. I think, even
given its name, that it doesn't take itself too seriously with providing
the most practical tooling for CI integration, but it certainly gets points for
not choking on the code.

5. slamhound (automatically clean up namespaces)
6. spectrum (static checking based on specs)
7. lein-nvd (vulnerability check in dependencies)
8. orchestra (automatic spec validation for every fn call)
9. lein-cloverage

noteworthy

* https://github.com/quality-clojure/qualityclj