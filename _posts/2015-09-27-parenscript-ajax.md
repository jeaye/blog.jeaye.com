---
title: Common Lisp, Parenscript, and AJAX
tags: [lisp, parenscript, ajax, tutorial]
---

When looking to make full-stack web applications in lisp, Common Lisp and Parenscript are just as capable as Clojure and Clojurescript, if only less documented. As I wanted to make a web-based REPL for [jank](https://github.com/jeaye/jank), my statically-typed functional programming language, I evaluated both the Clojure and Common Lisp stacks and, ultimately, decided on Common Lisp.

The goal of this post is not to compare the Common Lisp and Clojure stacks, but is, instead, to offer an updated introduction to actually getting the Common Lisp stack running. Unfortunately, *every single* example and tutorial I've found on the topic has *something* incorrect. The minimal scope of this post, hopefully, will maximize its portability and longevity.

### Dependencies
To begin with, we'll sort out our dependencies. This was tested using SBCL 1.2.15.79-c2708da on Slackware 14.1 x86_64, but it should have no issues elsewhere.

1. [parenscript](https://common-lisp.net/project/parenscript/) (a set of macros for turning Common Lisp into Javascript)
2. [hunchentoot](http://weitz.de/hunchentoot/) (a pure Common Lisp web server)
3. [cl-who](http://weitz.de/cl-who/) (a DSL for building HTML, compatible with Parenscript)
4. [smackjack](https://github.com/aarvid/SmackJack) (an AJAX library we'll use from Parenscript)

We'll just use [quicklisp](https://www.quicklisp.org/beta/) to install these for us.

```lisp
(ql:quickload '(:hunchentoot :cl-who :parenscript :smackjack))
```

### Package
After that, we'll define a package for our application. In my case, it's `:jank-repl`.

```lisp
(defpackage :jank-repl
  (:use :cl :hunchentoot :cl-who :parenscript :smackjack))
(in-package :jank-repl)
```

### Starting the server
At this point, we can tell Hunchentoot to start up. It won't do much, but it'll allow us to verify everything is good so far.

```lisp
(defparameter *server*
  (start (make-instance 'easy-acceptor :address "localhost" :port 8080)))
```

We specify the `'easy-acceptor` so that Hunchentoot will detect our custom routes later on, automatically. Different acceptors can be added to a global `*dispatch-table*`, which we'll see later.

**NOTE:** Many Hunchentoot examples and tutorials will use `'acceptor` instead of `'easy-acceptor`. Do *not* do this unless you know what you're doing. Nothing will work.

Now we can try connecting to the server, either through our browser, or simply via curl.

```bash
curl "http://localhost:8080/"
```

If all is working well, you should get a simple page back saying something like "Welcome to Hunchentoot!" We can now start adding some custom pages.

### Adding custom pages
Before we jump into using cl-who with Hunchentoot, we need to tell Parenscript how to escape its strings when embedded in cl-who.

```lisp
; Allow cl-who and Parenscript to work together
(setf *js-string-delimiter* #\")
```

Now we can define a custom route using Hunchentoot's `define-easy-handler` macro.

```lisp
(define-easy-handler (repl :uri "/repl") ()
  (with-html-output-to-string (s)
    (:html
      (:body
        (:h2 "Jank REPL")))))
```

This macro will setup routing for us, requiring no extra Hunchentoot code. As you can see, we use cl-who here to build html into a string. The return value of this handler is the html (or other content, if desired) of the webpage.

After restarting the server, we can now test out this new page.

```bash
curl "http://localhost:8080/repl"
```

### Setting up a remote API
To have our server start responding to queries, we'll begin integrating SmackJack into our source. To start, we need an AJAX processor operating at a specific URI.

```lisp
(defparameter *ajax-processor*
  (make-instance 'ajax-processor :server-uri "/repl-api"))
```

After that, we can register remote functions with it using SmackJack's `defun-ajax` macro. We'll start with a simple echo function. The `:callback-data` can be various types, from text to JSON, to XML. For now, we'll just echo text.

```lisp
(defun-ajax echo (data) (*ajax-processor* :callback-data :response-text)
  (concatenate 'string "echo: " data))
```

The last thing we need to do, in order for us to access our remote functions through Hunchentoot, is integrate the AJAX handler with Hunchentoot's dispatch table.

```lisp
(setq *dispatch-table* (list 'dispatch-easy-handlers
                             (create-ajax-dispatcher *ajax-processor*)))
```

Now we can test the server!

```bash
curl 'http://localhost:8080/repl-api/ECHO?data="testing!"'
```

**NOTE:** The capitalization of `ECHO` here and the quoting of the `data` value is very deliberate. This is also something that many examples/tutorials will get wrong.

### Calling from Parenscript
The last thing we have to do is call our server from the client. We'll spice up our REPL page to have some Parenscript and we'll use the echo server with SmackJack to reply to the client.

In order to access our AJAX functions from Parenscript, we need to bring in SmackJack's prologue, which is just a generated dump of JavaScript wrappers. Aside from that, we'll need to define a two Parenscript functions.

1. Something to call when an event on the page happens; it calls into SmackJack
2. A callback for when we hear back from the server

Let's see how that looks:

```lisp
(define-easy-handler (repl :uri "/repl") ()
  (with-html-output-to-string (s)
    (:html
      (:head
        (:title "Jank REPL")
        (str (generate-prologue *ajax-processor*))
        (:script :type "text/javascript"
          (str
            (ps
              (defun callback (response)
                (alert response))

              (defun on-click ()
                (chain smackjack (echo (chain document
                                              (get-element-by-id "data")
                                              value)
                                       callback)))))))
      (:body
        (:p
          (:input :id "data" :type "text"))
        (:p
          (:button :type "button"
                   :onclick (ps-inline (on-click))
                   "Submit!"))))))
```

This is quite a bit larger than our previous `/repl` Hunchentoot handler, but the pieces are quite simple. First, we see we're generating SmackJack's prologue. We need to use cl-who's `str` function to marshal Common Lisp strings into the HTML generation. Aside from that, we're defining a script tag with some Parenscript, denoted by `ps`.

As mentioned before, we have two Parenscript functions. One handles the initial event and the other handles the callback from the server. I'll point out a couple of subtle bits which other examples and tutorials get wrong.

1. We use `chain` to access nested functions within Parenscript objects
2. We use `ps-inline` to generate JavaScript prefixed with "javascript:"

Now navigate to http://localhost:8080/repl and jot something into the text box. When you click the submit button, you'll contact the server. Once the server's reply comes back, your window  will be alerted with the response.

### Wrapping up
The full source for this can fit comfortably under 50 lines, which is great, considering it's both the front end and back end logic. However, the state of documentation for these projects, most of which have been stale for a matter of years, is very unfortunate. Even a matter of 50 lines can prove to be several hours of head pain.

Of course, this isn't quite a REPL yet, but all of the necessary glue work between the client and server is entirely done. Now it's just a matter of cleaning up the UI and implementing the backend logic.

The full source is shown below, as well as some references I used while piecing this together.

### Full source

```lisp
(ql:quickload '(:hunchentoot :cl-who :parenscript :smackjack))

(defpackage :jank-repl
  (:use :cl :hunchentoot :cl-who :parenscript :smackjack))
(in-package :jank-repl)

; Allow cl-who and parenscript to work together
(setf *js-string-delimiter* #\")

(defparameter *ajax-processor*
  (make-instance 'ajax-processor :server-uri "/repl-api"))

(defun-ajax echo (data) (*ajax-processor* :callback-data :response-text)
  (concatenate 'string "echo: " data))

(define-easy-handler (repl :uri "/repl") ()
  (with-html-output-to-string (s)
    (:html
      (:head
        (:title "Jank REPL")
        (str (generate-prologue *ajax-processor*))
        (:script :type "text/javascript"
          (str
            (ps
              (defun callback (response)
                (alert response))

              (defun on-click ()
                (chain smackjack (echo (chain document
                                              (get-element-by-id "data")
                                              value)
                                       callback)))))))
      (:body
        (:p
          (:input :id "data" :type "text"))
        (:p
          (:button :type "button"
                   :onclick (ps-inline (on-click))
                   "Submit!"))))))

(defparameter *server*
  (start (make-instance 'easy-acceptor :address "localhost" :port 8080)))

(setq *dispatch-table* (list 'dispatch-easy-handlers
                             (create-ajax-dispatcher *ajax-processor*)))
```

### References
Note that *many* of these are out of date. Compare the usages you find with what's shown above to have a higher chance of bringing in working code.

- [Official Parenscript tutorial](https://common-lisp.net/project/parenscript/tutorial.html)
- [Other Parenscript tutorial](http://vitovan.com/lispweb3.html)
- [Parenscript tips](http://www.cliki.net/ParenscriptTipsAndTricks)
- [SmackJack Demo](https://github.com/aarvid/SmackJack/blob/master/demo/demo.lisp)
