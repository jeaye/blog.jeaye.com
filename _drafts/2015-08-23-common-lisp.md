---
title: Common Lisp
tags: [lisp, review]
---

shared values/pointers
  not safe when mutating

setf? setq?
  should just be set!

setq
  works globally, even from within a function!
  of course, there's always defvar and defparameter... -_-

keywords aren't type-safe

aref
  should be generic
  doesn't do static size checking

uses struct name prefix for member access instead of types

separate namespace for functions (need for #')

annoying comparisons
  eq, eql, equal, string-equal, what else?

shouldn't need (in-package) after a (defpackage)

print, prin1, princ
  seriously? awful naming

print functions rely on global state settings
  like miser width

reader macros are nasty

open/close with files
  no RAII, need to use with-open-file but it can be forgotten

if you don't specify most things, they're nil
    thus, you can realize 10 calls later that you fucked up

almost nothing is atomic in lisp

some predicates use p suffix, others don't
  numberp, atom
