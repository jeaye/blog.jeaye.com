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

### [eastwood](https://github.com/jonase/eastwood) (linter) [active | doesn't work]
```clojure
[jonase/eastwood "0.2.4"]
```

Eastwood is a great looking linter for Clojure, but it's unable to run on the
server code, since it doesn't support namespaced maps. In the namespaces where
it does run, it raises the same false positive over and over.

#### Relevant tickets
* Namespaced maps: https://github.com/jonase/eastwood/issues/201
* False positives: https://github.com/jonase/eastwood/issues/227

2. yagni (dead code finding)
3. kibit (idiom suggester)
4. [lein-bikeshed](https://github.com/dakrone/lein-bikeshed) (checks for code cleanliness)
5. slamhound (automatically clean up namespaces)
6. spectrum (static checking based on specs)
7. lein-nvd (vulnerability check in dependencies)
8. orchestra (automatic spec validation for every fn call)
9. lein-cloverage

noteworthy

* https://github.com/quality-clojure/qualityclj
