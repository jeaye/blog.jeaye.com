---
title: Intro to relational programming with Clojure
tags: [clojure, programming, tutorial]
---

Call checking:
```clojure
(defn check-call [f a]
  (run* [q]
        (membero q (first f))
        (== q a)))

(defn -main
  [& args]
  (let [f [[:int] [:float]]
        a :int
        q (check-call f a)]
    (println q)))
```

Overload resolution:
```clojure
(defn match [fs a]
  (run* [q']
        (membero q' fs)
        (fresh [a' r']
               (== q' [[a] r']))))

(defn -main
  [& args]
  (let [fs [[[:int] [:float]]
            [[:float] [:float]]]
        a :int
        q (match fs a)]
    (println q)))
```
