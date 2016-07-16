---
title: Intro to relational programming with Clojure
tags: [clojure, programming, tutorial]
---

Call checking:
```clojure
(defn check-call [f a]
  (run* [q']
        (fresh [r']
               (== q' [[a] r']))))

(defn -main
  [& args]
  (let [f [[:int] [:void]]
        a :int
        q (check-call f a)]
    (println q)))
```

Overload resolution:
```clojure
(defn match [fs a]
  (run* [q']
        (membero q' fs)
        (fresh [r']
               (== q' [[a] r']))))

(defn -main
  [& args]
  (let [fs [[[:int] [:void]]
            [[:float] [:void]]]
        a :int
        q (match fs a)]
    (println q)))
```

Multiple arguments:
```clojure
(defn match [fs as]
  (run* [q']
        (membero q' fs)
        (fresh [r']
               (== q' [as r']))))

(defn -main
  [& args]
  (let [fs [[[:int] [:void]]
            [[:int :int] [:void]]
            [[:int :float] [:void]]
            [[:float] [:void]]]
        as [:float]
        q (match fs as)]
    (println q)))
```
