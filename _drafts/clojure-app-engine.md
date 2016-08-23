---
title: Running Clojure on Google App Engine
tags: [clojure, programming, appengine, google, tutorial]
---

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
