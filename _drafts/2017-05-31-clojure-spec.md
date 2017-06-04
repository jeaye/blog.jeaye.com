---
title: Clojure devs: use clojure.spec please
tags: [clojure, spec, rant, dependent types, safety]
---

Clojure 1.9 has introduced a novel library,
[clojure.spec](https://clojure.org/about/spec), which allows developers to parse
and validate data using a predicative API which is just composed of Clojure
functions. If there's one thing Clojure's good at, though there's not just one,
it's the [pure](https://en.wikipedia.org/wiki/Pure_function) transformation of
data. With spec, that grasp is broadened to allow for exceedingly expressive
validation of data as well. What's most important is that Clojure developers
understand this new tool and use it to improve the safety and readability of
their code.

### Learning clojure.spec
It's been around long enough for there to be some great introductory material.
There's an official [Rationale and Overview](https://clojure.org/about/spec),
thorough [Spec Guide](https://clojure.org/guides/spec), more illustrative [Video
Introduction](https://lambdaisland.com/episodes/clojure-spec), etc. This post
assumes a working understanding of spec, since its goal is to talk more about
its practical applications.
