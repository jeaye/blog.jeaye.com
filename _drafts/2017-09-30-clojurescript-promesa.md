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

### The JavaScript
This example references [Appium](http://appium.io/) and
[webdriver.io](http://webdriver.io/) since they're what I was using when
initially researching promesa. This isn't the best example usage of `await`, but
it allows the code to read as though it works synchronously, even though each
line is awaiting a promise.

```javascript
async function sign_in() {
  await driver.init().timeoutsImplicitWait(120 * 1000);

  await driver.waitForVisible("~email");
  await driver.element("~email").setValue("test@example.com");
  await driver.click("~sign-in");

  await driver.pause(1000).end();
}
```

### The first pass
The first attempt won't be the cleanest, but it'll mimic the functionality.
```clojure
(ns my-app.test.sign-in
  (:require [[oops.core :refer [ocall]]
             [promesa.core :as p]
             [promesa.async-cljs :refer-macros [async]]]))

(defn sign-in []
  (async
    (-> driver
        (ocall :init) (ocall :timeoutsImplicitWait (* 120 1000))
        p/await)

    (-> driver
        (ocall :waitForVisible "~email")
        p/await)

    (-> driver
        (ocall :element "~email") (ocall :setValue "test@example.com")
        p/await)

    (-> driver
        (ocall :click "~email")
        p/await)

    (-> driver
        (ocall :pause 1000)
        (ocall :end)
        p/await)))
```

TODO: Mention cljs-promises
