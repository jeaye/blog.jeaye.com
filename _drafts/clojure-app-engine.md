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

#### State of third-party libraries
When looking to start with Clojure on App Engine, you might explore the current
open source libraries available. Unfortunately, there are a few, namely
[appengine-magic](https://github.com/gcv/appengine-magic), yet all of them have
been stale for at least two years. Most of them are built on Clojure 1.4 or
older.

#### State of official documentation
Your next step may be to see what official documentation there is, since you
can't readily use a third-party library to do your dirty work. App Engine's
[documentation](https://cloud.google.com/appengine/docs) can be very helpful, no
doubt, but one issue is that App Engine supports JVM applications, not
specifically Clojure applications. Its examples are in Java, using Maven, and
the typical serving of XML. The docs will come in handy, once you can get some
basic App Engine code working, but they don't get you over that hurdle. Not in
Clojure.

#### State of third-party documentation
Before giving up, you do some searching for what others have done. *"Surely
someone's made an application for GAE sometime after 2014,"* you think.
Fortunately, you'll likely happen across a few good resources. Unfortunately,
most of them are vacant mailing list threads and/or even more dated than the
abandoned libraries. If you landed here, I'll save you the trouble and provide
you with what's been most helpful for me:

1. http://lambda-startup.com/developing-clojure-on-app-engine/
2. http://flowa.fi/blog/2014/04/25/clojure-gae-howto.html

In that order.

Still, there are unclear bits, omitted bits, outdated bits, and inconsistencies
between the two of them. So, doing my part, I'll expand upon the first resource
and provide some clarifications, tools, and useful tips. I recommend you give
both a read, without following along in the repl/editor, so you have an idea of
what's required.

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

  No method in multimethod 'render-map-generic' for dispatch value: null

    use pr-str instead of returning a map

spoke with cognitect; no news yet
