---
title: Intro to relational programming with Clojure
tags: [clojure, programming, tutorial]
---

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
