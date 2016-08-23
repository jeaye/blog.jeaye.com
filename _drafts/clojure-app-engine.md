---
title: Running Clojure on Google App Engine
tags: [clojure, programming, appengine, google, tutorial]
---

Clojure excels at pure transformations of persistent data. One application of
that which works quite well is stateless servers, which transform data between
the client and the datastore. For distributed server development in Clojure, we
already have [Onyx](http://www.onyxplatform.org/), as well as [wrappers for
Mesos](https://github.com/pyr/mesomatic) and others. An apparently less explored
option is using Clojure on Google App Engine, which runs sandboxed applications
in Google-managed data centers while providing automatic scaling.

guide:
  http://lambda-startup.com/developing-clojure-on-app-engine/

appengine-magic is worth inspecting; it's untouched since 2014 though
  the query bits, especially

errors:
  Compilation failed: No method in multimethod 'print-dup' for dispatch value:
  class org.sonatype.aether.repository.RemoteRepository

    upgrade lein-ring to 0.9.7

  No API environment is registered for this thread

    don't use datastore from repl; use it from program only

  Compiling app-engine in uberwar

    move the source into a separate dir and only have it in the :dev profile

  status 400 when accessing liberator/compojure routes

    liberator is the issue - watch your MIME types! my content-type was nil

spoke with cognitect; no news yet
