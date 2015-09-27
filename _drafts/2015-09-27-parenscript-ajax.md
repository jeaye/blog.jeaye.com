---
title: Common Lisp, Parenscript, and AJAX
tags: [lisp, parenscript, ajax, tutorial]
---

When looking to make full-stack web applications in lisp, Common Lisp and Parenscript are just as capable as Clojure and Clojurescript, if only less documented. While looking to make a web-based REPL for [jank](TODO), my statically-typed functional programming language, I evaluated both the Clojure and Common Lisp stacks and, ultimately, decided on Common Lisp.

The goal of this post is not to compare the Common Lisp and Clojure stacks, but is, instead, to offer an updated introduction to actually getting the Common Lisp stack running. Unfortunately, *every single* example and tutorial I've found on the topic has *something* incorrect. The minimal scope of this post, hopefully, will maximize its portability.

### Dependencies
To begin with, we'll sort out our dependencies. This was tested using SBCL 1.2.15.79-c2708da on Slackware 14.1 x86_64, but it should have no issues elsewhere.

1. [parenscript](TODO) (a set of macros for turning Common Lisp into Javascript)
2. [hunchentoot](TODO) (a pure Common Lisp web server)
3. [cl-who](TODO) (a DSL for building HTML, compatible with Parenscript)
4. [smackjack](TODO) (an AJAX library used for contacting the server)

We'll just use [quicklisp](TODO) to install these for us.

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
At this point, we can tell hunchentoot to start up. It won't do much, but it'll allow us to verify everything is good so far.

```lisp
(defparameter *server*
  (start (make-instance 'easy-acceptor :address "localhost" :port 8080)))
```

TODO: mention 'acceptor bug

Now we can try connecting to the server, either through our browser, or simply via curl.

```bash
curl "http://localhost:8080/"
```

If all is working well, you should get a simple page back saying something like "Welcome to Hunchentoot!" We can now start adding some custom pages.

### Adding custom pages
Before we jump into using cl-who with hunchentoot, we need to tell parenscript how to escape its strings when embedded in cl-who.

```lisp
; Allow cl-who and parenscript to work together
(setf *js-string-delimiter* #\")
```

Now we can define a custom route using hunchentoot's `define-easy-handler` macro.

```lisp
(define-easy-handler (repl :uri "/repl") ()
  (with-html-output-to-string (s)
    (:html
     (:body
      (:h2 "Jank REPL")))))
```

This macro will setup routing for us, requiring no extra hunchentoot code. As you can see, we use cl-who here to build html into a string. The return value of this handler is the html (or other content, if desired) of the webpage.

After restarting the server, we can now test out this new page.

```bash
curl "http://localhost:8080/repl"
```
