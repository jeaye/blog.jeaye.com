---
title: Async/await in ClojureScript with Promesa
labels: [clojure, tutorial]
tags: [tutorial, clojure, promesa]
---

JavaScript (ES7/ES2016) introduced `async` and `await` as a clean way of working
with
[promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises).
When porting this sort of asynchronous code to ClojureScript, it may be
disappointing that there's no equivalent language feature. Some may say "use
[core.async](https://github.com/clojure/core.async)," which is a fine
suggestion, but it may not work with the existing JS promises/thenables.
This is where [promesa](https://github.com/funcool/promesa) comes in. promesa is
a Clojure/Script library for working with native promises; it also provides
macro support for `async`/`await` and uses `core.async` machinery behind the
scenes.
