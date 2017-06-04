---
title: Dear Clojure devs, use clojure.spec please
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
spec's practical applications.

### Why spec?
Knowing how spec works and even how to use it is handy. Still, why bother
spec'ing? If you look at the spec docs linked above, most reasons are for the
aid in [testing](https://en.wikipedia.org/wiki/Software_testing), specifically
with [generative testing](https://clojure.org/guides/spec#_generators). That's
great, if you like writing tests, or if your tests aren't already written in
something else. What if that's not the case?

*Please. Still use clojure.spec.*

Here's why.

### Instrumentation
A hugely overlooked aspect of spec is its
[instrumentation](https://clojure.org/guides/spec#_instrumentation_and_testing).
In short, if you spec your functions and your data, you can ask Clojure to
automatically check every single function call to make sure the arguments are
correct. Not just during testing, but during development or even production.
Furthermore, if you use [Orchestra](https://github.com/jeaye/orchestra), then
Clojure can automatically check every function's return value against its spec,
among other things.

*This is superb.*

Coming from C++, or Java, or C#, or so many other languages: have you been able
to easily instrument every single function to validate it's working properly?
Not just with static types, which can be quite limiting, but with arbitrary
predicates written in the same language you're using? Unlikely.

Let's look at some code.

#### Simple math
```clojure
(defn my-inc [x]
  (inc x))
```

This is a simple function, so it's easy to tell what `x` needs to be. In more
complex functions, that's not always the case. Now, what if we were to call this
with something other than a number?

```clojure
(my-inc nil) ; => java.lang.NullPointerException
(my-inc "ok") ; => java.lang.ClassCastException
```

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

Just a single example should be descriptive enough, once we [enable
Orchestra](https://github.com/jeaye/orchestra#usage).

```clojure
user=> (my-inc "ok")
clojure.lang.ExceptionInfo: Call to #'user/my-inc did not conform to spec:
                            In: [0] val: "ok" fails at: [:args :x] predicate: number?
                            :clojure.spec.alpha/spec #object[...]
                            :clojure.spec.alpha/value ("ok")
                            :clojure.spec.alpha/args ("ok")
                            :clojure.spec.alpha/failure :instrument
                            :orchestra.spec.test/caller {:file "form-...",
                                                         :line 1,
                                                         :var-scope user/eval42203}
```

That's gorgeous. Before we get into the function, we're stopped with some very
detailed information that `[:args :x]` (the argument called `x`) was supposed to
match `number?`, but it has the value of `"ok"`. We also get to see all the
other args to the function, line/file info, etc. Compared to typical
statically-typed languages, and the typical Clojure exceptions, which say
"expected number, got string," we're now dealing with values, not just types. In
this way, spec behaves more like a [dependent
type system](https://en.wikipedia.org/wiki/Dependent_type).

The most important aspect has yet to be mentioned: if a Clojure library provides
these specs for its functions and data, any consumers using Orchestra and spec
will immediately be able to benefit from automatic instrumentation. Each spec is
also a form of documentation which must be up-to-date with the code (or
instrumentation would fail!).

#### More complex map extraction
```clojure
; This behaves similarly to clojure.core/select-keys
(defn extract
  "Given a map and some keys, return a map with only those keys"
  [m ks]
  (reduce (fn [acc k]
            (let [v (get m k)]
              (if (some? v)
                (assoc acc k v)
                acc)))
          {}
          ks))
(s/fdef extract
        :args (s/cat :m map?
                     :ks (s/coll-of any?))
        :fn (fn [ctx]
              (= (into #{} (-> ctx :args :ks))
                 (into #{} (-> ctx :ret keys))))
        :ret map?)
```

In this example, we can use Orchestra to take advantage of spec's `:fn` spec.
These are executed at the end of a function call, and they're given both the
arguments and the return value. In this case, we can verify that the keys of the
output map are exactly the keys meant to be extracted. Note, this expects that
all keys were present, but that's the sort of control which you can embed and
automatically run on each function call.

If we intentionally add a bug, where we use `if-let` instead of `if-some` or
`some?`, this function won't work well with `false`.

```clojure
(defn extract
  "Given a map and some keys, return a map with only those keys"
  [m ks]
  (reduce (fn [acc k]
            (if-let [v (get m k)]
              (assoc acc k v)
              acc))
          {}
          ks))
```

With instrumentation enabled, here's what we might see. Since it's the `:fn`
spec which fails, the error will give us all of the argument values, as well as
the return value. It gives use the predicate which failed and dropping them all
in the REPL would allow us to figure out exactly why.

```clojure
user=> (extract {:foo 0 :bar false :spam "meow"} [:bar])

clojure.lang.ExceptionInfo: Call to #'user/extract did not conform to spec:
                            val: {:ret {},
                                  :args {:m {:foo 0, :bar false, :spam "meow"},
                                         :ks [:bar]}}
                            fails at: [:fn]
                            predicate: (fn [ctx]
                                         (= (into #{} (-> ctx :args :ks))
                                            (into #{} (-> ctx :ret keys))))
                            :clojure.spec.alpha/spec  #object[...]
                            :clojure.spec.alpha/value {:ret {},
                                                       :args {:m {:foo 0, :bar false, :spam "meow"},
                                                              :ks [:bar]}}
                            :clojure.spec.alpha/fn {:ret {},
                                                    :args {:m {:foo 0, :bar false, :spam "meow"},
                                                           :ks [:bar]}}
                            :clojure.spec.alpha/failure :instrument
                            :orchestra.spec.test/caller {:file "form-...",
                                                         :line 1,
                                                         :var-scope user/eval53563}
```

### A real-world example
Just recently, I opened a [pull request to
Reagent](https://github.com/reagent-project/reagent/pull/301), which is an
excellent project, in hopes of improving its input validation and error
messages. Rather than using spec, it's performing manual asserts on input data
and then providing adhoc error messages on failed validation. My PR keeps the
asserts, but refactors them to common helpers and improves the messages
(introducing new deps isn't typically the right first step in improving a
library as an outsider). Still, we can do so much better than that. These can be
checked for us and we can describe the shape of the data as it should be when it
flows through our Clojure machines.

### Performance implications
Automatically instrumenting every single function call, checking all the
arguments, return values, and possibly `:fn` specs sounds pretty slow, right?
You may be surprised. For development, I've seen absolutely no notable
performance issues running Orchestra and instrumenting just about every function
in a back-end deployment of Ring + Compojure + PostgreSQL. Your mileage may
vary, but this is something you should try first, get as much out of it as you
can, and only put down if you absolutely must.

For the safety of your programs and the programs of everyone using your
libraries, Clojure devs, please spec out your functions and your data. If you
want help writing your specs, heck, email me and let's get it done. Clojure devs
deserve the huge win of automatic instrumentation.
