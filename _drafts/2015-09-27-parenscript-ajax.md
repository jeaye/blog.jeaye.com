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
