---
title: The state of code quality tools in Clojure 1.9
tags: [clojure, spec, orchestra, survey, continuous-integration, safety]
---

There are several projects for verifying quality and correctness in Clojure code
bases.  When surveying how they'll work on a distributed Clojure server built
for Heroku & Postgres, I took some notes on the issues that came up. These notes
represent the current state of things, as well as how we, the Clojure community,
can help move them forward.

Out of the nine projects evaluated, only three of them worked, and only two were
immediately useful for CI. It's worth noting that the codebase being tested is
nothing special, in terms of features used, but it does contain cljc files
shared between Clojure and ClojureScript and it makes heavy use of spec and
namespace-qualified keywords. Apparently this causes a lot of issues with
tooling!

### Project: [eastwood](https://github.com/jonase/eastwood)
```clojure
[jonase/eastwood "0.2.4"]
```

Eastwood is a great looking linter for Clojure. It's designed to find all sorts
of issues and code smells, but it's unfortunately unable to run on the server
code, since it doesn't support namespaced map literals. In the namespaces where
it does run, it raises the same false-positive over and over.

#### Relevant tickets
* [Namespaced maps](https://github.com/jonase/eastwood/issues/201)
* [False positives](https://github.com/jonase/eastwood/issues/227)

### Project: [yagni](https://github.com/venantius/yagni)
```clojure
[venantius/yagni "0.1.4"]
```

yagni is an acronym for [You Aren't Gonna Need
It](https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it) and the project is
a dead code finder (the only one of its kind, in the Clojure world).
Unfortunately, it doesn't support reader conditionals and it also chokes on the
usage of spec.

#### Relevant tickets
* [Reader conditionals](https://github.com/venantius/yagni/issues/37)
* [Spec usage](https://github.com/venantius/yagni/issues/36)

### Project: [kibit](https://github.com/jonase/kibit)
```clojure
[lein-kibit "0.1.5"]
```

kibit is an analyzer which uses core.logic to search for patterns in code
which can be written to be more idiomatic. Like many other tools on this list,
kibit struggles with parsing some Clojure, like nested requires and reader
conditionals.

#### Relevant tickets
* [Nested requires](https://github.com/jonase/kibit/issues/202)
* [Reader conditionals](https://github.com/jonase/kibit/pull/194)

### Project: [lein-bikeshed](https://github.com/dakrone/lein-bikeshed)
```clojure
[lein-bikeshed "0.4.1"]
```

lein-bikeshed is one of the few tools which worked out of the box.
Unfortunately, the output wasn't terribly useful. The two issues reported were
that some lines are longer than 80 characters and some functions missing doc
strings. I think, given its name, that lein-bikeshed doesn't take itself too
seriously in providing the most practical tooling for CI integration, but it
certainly gets points for not choking on the code.

### Project: [slamhound](https://github.com/technomancy/slamhound)
```clojure
[slamhound "1.5.5"]
```

By only comparing the descriptions, slamhound seemed like one of the most useful
ones of the bunch. It has the ability to clean up namespace aliases, add
requires, and even remove unused requires.

Unfortunately, it hasn't been maintained for a year and has started sprouting
various issues and PRs which go unloved. More importantly, it fails to parse
aliased keywords, as well as the parsing of dotted namespace aliases.

#### Relevant tickets
* [Aliased keywords](https://github.com/technomancy/slamhound/issues/79)
* [Dotted namespace alias](https://github.com/technomancy/slamhound/pull/87)

### Project: [spectrum](https://github.com/arohner/spectrum)
Spectrum is the one on this list which is most exciting for use with CI. It
performs static analysis and, using both specs and type inference, determines if
code is incorrect without running it. Given how robust specs can be, reaching
into the land of dependent types, this is a very promising avenue.
Unfortunately, after speaking with the developer for a bit, it's clear that
spectrum isn't yet ready to use.

In preparation for it, [spec your
functions!]({{ site.blog_url }}/2017/05/31/clojure-spec/)

### Project: [lein-nvd](https://github.com/rm-hull/lein-nvd)
```clojure
[lein-nvd "0.3.0"]
```

*This tool is a must.* Furthermore, it worked without issue. It crawls through a
project's dependencies and checks for vulnerable versions of libraries. If
there's a known vulnerability in one of your dependencies, it informs you and
also conveys the severity of the issue. I don't see why a Clojure back-end would
run CI without this.


### Project: [orchestra](https://github.com/jeaye/orchestra)
```clojure
[orchestra "2017.08.13"]
```

Orchestra is a Clojure library made as a drop-in replacement for
clojure.spec.test.alpha, which provides custom instrumentation that validates
all aspects of function specs. Best of all, it works out of the box on this
source code and can be used during testing, development, and even production.


### Project: [cloverage](https://github.com/cloverage/cloverage)
```clojure
[lein-cloverage "1.0.9"]
```

I've [written about cloverage
before]({{ site.blog_url }}/2016/12/29/clojure-test-coverage/) and I'll
recommend it again. cloverage will report how much coverage your tests have by
instrumenting the code to see which functions are called, which branches are
taken, etc. It works out of the box with this code base and integrates very
nicely into a CI setup.

## Striking similarities
There are some promising tools out there, just in the Clojure JVM world, for
verifying code quality and correctness, automatically making improvements, or
even just suggesting cleaner idioms. It seems like most of them, in fact, are
struggling with parsing Clojure code, be it reader conditionals, namespace
aliases, nested requires, or aliased keywords. Given that this is a consistent
problem across several projects and several authors, there is an indication of
insufficient or unreliable tooling when it comes to statically reading Clojure
code. This is likely due to Clojure's dynamic nature, but, nevertheless, there's
an untapped market here.

Given all of the tickets linked above, I encourage readers to try out these
projects on their code bases, issue more tickets, ping maintainers, and
contribute some PRs. Lastly, if there's a project that should be on this list,
email me!
