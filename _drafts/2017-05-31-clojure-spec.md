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

### Why spec?
Knowing how spec works and even how to use it is handy. Still, why bother
spec'ing? If you look at the spec docs linked above, most reasons are for the
aid in [testing](https://en.wikipedia.org/wiki/Software_testing), specifically
with [generative testing](https://clojure.org/guides/spec#_generators). That's
great, if you like writing tests, or if your tests aren't already written in
something else. What if that's not the case?

*Please. Still use clojure.spec. Here's a motivating example.*

### Instrumentation
A hugely overlooked aspect of spec is its
[instrumentation](https://clojure.org/guides/spec#_instrumentation_and_testing).
In short, if you spec your functions and your data, you can ask Clojure to
*automatically check every single function call* to make sure the arguments are
correct. Furthermore, if you use
[Orchestra](https://github.com/jeaye/orchestra), then Clojure can *automatically
check every function's return value against its spec*, among other validators.

*This is huge.*

Coming from C++, or Java, or C#, or so many other languages: have you been able
to easily instrument every single function to validate it's working properly?
Not just with static types, which can be quite limiting, but with arbitrary
predicates written in the same language you're using? Let's look at some
examples.

#### Simple math
```clojure
(defn my-inc [x]
  (inc x))
```

What if we were to call this with something other than a number?

* `(my-inc nil)` => `java.lang.NullPointerException`
* `(my-inc "ok")` => `java.lang.ClassCastException`

Those are pretty helpful. The exception will include a stack trace, so you can
get the line number and find the right function. Let's spec out that function
and see what we'd get with instrumentation enabled.

```clojure
(require '[clojure.spec.alpha :as s])

(defn my-inc [x]
  (inc x))
(s/fdef my-inc
      :args (s/cat :x number?)
      :ret number?)
```

Just a call to `(my-inc "ok")` should be descriptive enough, once we [enable
Orchestra](https://github.com/jeaye/orchestra#usage).

```clojure
clojure.lang.ExceptionInfo: Call to #'user/my-inc did not conform to spec:
                            In: [0] val: "ok" fails at: [:args :x] predicate: number?
                            :clojure.spec.alpha/spec  #object[clojure.spec.alpha$regex_spec_impl$reify__1200 0x5422f7a "clojure.spec.alpha$regex_spec_impl$reify__1200@5422f7a"]
                            :clojure.spec.alpha/value  ("ok")
                            :clojure.spec.alpha/args  ("ok")
                            :clojure.spec.alpha/failure  :instrument
                            :orchestra.spec.test/caller  {:file "form-init6204324603710300718.clj", :line 1, :var-scope user/eval42203}
```

That's gorgeous. Before we get into the function, we're stopped with some very
detailed information that `[:args :x]` (the argument called `x`) was supposed to
match `number?`, but it has the value of `"ok"`. We also get to see all the
other args to the function, line/file info, etc.
