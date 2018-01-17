---
title: Clojure's forgotten for loop
labels: [clojure, tutorial]
tags: [clojure, functional, programming, tutorial]
---

Higher order functions in Clojure get a great deal of attention, and for good
reason. Clojure has a [rich standard library](http://www.clojureatlas.com/org.clojure:clojure:1.4.0.html) of functions which focus on purely transforming data. To those studying Clojure, the [for](https://www.conj.io/store/v1/org.clojure/clojure/1.8.0/clj/clojure.core/for) macro for list comprehension may stand out as verbose and awkward; it may also go entirely unnoticed.

### List comprehension
Many popular languages these days have [list comprehension](https://en.wikipedia.org/wiki/List_comprehension), more commonly [dynamic](https://en.wikipedia.org/wiki/Dynamic_programming_language) ones, and some are even rather [imperative](https://en.wikipedia.org/wiki/Imperative_programming), like Python. Here are some examples of how `for` can be used in Clojure.

#### Map
```clojure
(for [x (range 10 15)]
  (str "|" x "|"))

; => ("|10|" "|11|" "|12|" "|13|" "|14|")
```

#### Filter
The `:when` modifier allows filtering, based on a predicate. Iteration won't be
stopped, but any iteration which doesn't yield truthy from the predicate will be
skipped. In contrast, the `:while` modifier allows early termination, based on a
predicate. The `:while` predicate can only return false once, since `for` will
stop iterating immediately and return the accumulated result.

```clojure
(for [x {:a 1 "b" 2 :c 3}
      :when (-> x first keyword?)]
  x)

; => ([:a 1] [:c 3])

(for [x (range 3)
      y (range 3)
      :when (not= x y)]
  [x y])

; => ([0 1] [0 2] [1 0] [1 2] [2 0] [2 1])

(for [x (range 3)
      y (range 3)
      :while (not= x y)]
  [x y])

; => ([1 0] [2 0] [2 1])
```

#### Create intermediate bindings
It's possible to create bindings per-iteration; they have access to all bindings
above them.

```clojure
(for [i (range 1 10)
      :when (even? i)
      :let [inverse (/ 1 i)]]
  [i inverse])

; => ([2 1/2] [4 1/4] [6 1/6] [8 1/8])
```

#### Extract map values
It's possible to destructure within the bindings of `for`, allowing for easy
access to nested values.

```clojure
(for [[k v] {:a 1 :b 2 :c 3}]
  v)

; => (1 2 3)
```

#### Nested iteration
Subsequent bindings in the `for` macro will cause nested iteration, each
subsequent binding iterating more quickly than the former.

```clojure
(for [c [:2 :3 :4 :5 :6 :7 :8 :9 :10 :J :Q :K :A]
      s [:♠ :♥ :♣ :♦]]
  [c s])

; => ([:2  :♠] [:2  :♥] [:2  :♣] [:2  :♦]
;     [:3  :♠] [:3  :♥] [:3  :♣] [:3  :♦]
;     [:4  :♠] [:4  :♥] [:4  :♣] [:4  :♦]
;     [:5  :♠] [:5  :♥] [:5  :♣] [:5  :♦]
;     [:6  :♠] [:6  :♥] [:6  :♣] [:6  :♦]
;     [:7  :♠] [:7  :♥] [:7  :♣] [:7  :♦]
;     [:8  :♠] [:8  :♥] [:8  :♣] [:8  :♦]
;     [:9  :♠] [:9  :♥] [:9  :♣] [:9  :♦]
;     [:10 :♠] [:10 :♥] [:10 :♣] [:10 :♦]
;     [:J  :♠] [:J  :♥] [:J  :♣] [:J  :♦]
;     [:Q  :♠] [:Q  :♥] [:Q  :♣] [:Q  :♦]
;     [:K  :♠] [:K  :♥] [:K  :♣] [:K  :♦]
;     [:A  :♠] [:A  :♥] [:A  :♣] [:A  :♦])
```

#### Pairwise disjoint sets
The nested looping can be used to flatten nested sequences.

```clojure
(defn pairwise-disjoint? [s]
  (->> (for [s' s
             r s']
         r)
       (apply distinct?)))

(pairwise-disjoint? #{#{:a :b :c :d :e}
                      #{:a :b :c :d}
                      #{:a :b :c}
                      #{:a :b}
                      #{:a}})

; => false
```

### Worth noting
Those coming from the imperative camp may look to `for` to achieve [side-effects](https://en.wikipedia.org/wiki/Side_effect_%28computer_science%29). That won't work well, since Clojure's `for` is lazy; if it's not consumed, it'll never be realized. It may also only be partially consumed. Instead, consider [doseq](https://www.conj.io/store/v1/org.clojure/clojure/1.8.0/clj/clojure.core/doseq).

Most of the time, using `map` or `filter` will be not only more clear, but also
more concise. If you want early termination, however, or nested iterations, it's
worthwhile to know the semantics of Clojure's `for`.
