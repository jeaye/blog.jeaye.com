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

### Awaiting a JS promise
The first attempt won't be the cleanest, but it'll mimic the functionality. In
order to turn a JS promise, or, more correctly, any JS thenable, into a
[bluebird](http://bluebirdjs.com/docs/getting-started.html) promise (which is
what promesa uses behind the scenes), one needs to call `js/Promise.resolve`.
After resolving, the thenable will be a bluebird promise and all of the niceties
of promesa will be available.

```clojure
(ns my-app.test.sign-in
  (:require [[oops.core :refer [ocall]]
             [promesa.core :as p]
             [promesa.async-cljs :refer-macros [async]]]))

(defn sign-in []
  ; async is a promesa macro to allow for awaiting promises.
  (async
    (-> driver
        (ocall :init) (ocall :timeoutsImplicitWait (* 120 1000))
        ; We resolve the thenable into a bluebird promise...
        js/Promise.resolve
        ; Then we await the promise, just like in the JS version.
        p/await)

    ; The repeated resolve and await are an eye sore, but we can't just put them
    ; into a fn, since await can only be used within the async form. We need a
    ; macro.
    (-> driver
        (ocall :waitForVisible "~email")
        js/Promise.resolve
        p/await)

    (-> driver
        (ocall :element "~email") (ocall :setValue "test@example.com")
        js/Promise.resolve
        p/await)

    (-> driver
        (ocall :click "~sign-in")
        js/Promise.resolve
        p/await)

    (-> driver
        (ocall :pause 1000)
        (ocall :end)
        js/Promise.resolve
        p/await)))
```

### Removing some redundancy
Cleaning up the duplication can be done with a simple `await->` macro.

```clojure
; This must be a cljc file.
(ns my-app.test.util.macro
  (:require [promesa.core :as p]))

#?(:clj
   (defmacro await-> [thenable & thens]
     `(-> ~thenable
          ~@thens
          ~'js/Promise.resolve
          p/await)))
```

```clojure
(ns my-app.test.sign-in
  (:require [oops.core :refer [ocall]]
            [promesa.core :as p]
            [promesa.async-cljs :refer-macros [async]]
            [my-app.test.util.macro :refer-macros [await->]]))

(defn sign-in []
  (async
    (await-> driver
             (ocall :init) (ocall :timeoutsImplicitWait (* 120 1000)))

    (await-> driver
             (ocall :waitForVisible "~email"))

    (await-> driver
             (ocall :element "~email") (ocall :setValue "test@example.com"))

    (await-> driver
             (ocall :click "~sign-in"))

    (await-> driver
             (ocall :pause 1000)
             (ocall :end))))
```

### Sticking with core.async
For those interested in sticking with core.async, perhaps due to an existing
dependency, there is
[cljs-promises](https://github.com/jamesmacaulay/cljs-promises), which allows
the conversion of JS promises into async channels. Unlike bluebird's resolve,
cljs-promises doesn't work with all thenables though, so it's not as flexible as
promesa in that regard.
