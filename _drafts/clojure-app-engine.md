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
both a read, without following along in the REPL/editor, so you have an idea of
what's required.

#### Installing a local App Engine
When the very useful lambda-startup article gets to installing the App Engine
jars into your local repo, the instructions become unclear. To clarify,
`GAE_SDK` is where you have downloaded and extracted the SDK. The commands
should be executed from the working directory of your leiningen project. To make
things even simpler, use this script, named `install-gae`, in your project root:

```bash
#!/usr/bin/env bash

set -ue

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export gae_version=1.9.42
export gae_sdk="$here/lib/appengine-java-sdk-$gae_version"
export gae_zip="$gae_sdk.zip"

function install_gae
{
  if [ -d "$gae_sdk" ];
  then
    echo "GAE exists; not installing"
    return
  fi

  echo "Downloading GAE"
  mkdir -p "$here/lib"
  pushd "$here/lib"
    wget "https://storage.googleapis.com/appengine-sdks/featured/appengine-java-sdk-$gae_version.zip"
    unzip -q "$gae_zip"
  popd

  echo "Installing GAE"
  function gae_install
  { lein localrepo install "$gae_sdk/lib/$1" "com.google.appengine/$2" $gae_version; }

  gae_install impl/appengine-api-stubs.jar appengine-api-stubs
  gae_install impl/appengine-local-runtime.jar appengine-local-runtime
  gae_install shared/appengine-local-runtime-shared.jar appengine-local-runtime-shared

  echo "Done"
}
install_gae
```

#### Intricate errors
You may find some odd errors, when setting up your project, which yield very
little information, when searched.


* Compilation failed: No method in multimethod 'print-dup' for dispatch value:
  class org.sonatype.aether.repository.RemoteRepository

    The solution here is to upgrade lein-ring to 0.9.7; the lambda-startup docs
    are outdated and recommend 0.9.6.

* No API environment is registered for this thread

    This will happen if you try to use datastore from the REPL. Since it can
    only be accessed from one thread, I've only been able to do my datastore
    work from within the program. It's an annoyance, but not as serious of an
    issue as it first seemed.

* java.lang.ClassNotFoundException: com.google.appengine.tools.development.ApiProxyLocalFactory

    The lambda-startup resource doesn't mention that the provided App Engine
    wrapper source (`app-engine.clj`) should only be compiled in the `:dev`
    profile; it should not be included in the uberwar. To handle this, update
    your leiningen project to include another directory and move your
    `app-engine.clj` there.

    ```clojure
    :profiles {:dev {:source-paths ["dev/"]}}
    ```

    The `dev` directory might look like this.

    ```text
    dev
    └── my_app
        └── app_engine.clj
    ```


appengine-magic is worth inspecting; it's untouched since 2014 though
  the query bits, especially

errors:


  status 400 when accessing liberator/compojure routes

    liberator is the issue - watch your MIME types! my content-type was nil

  No method in multimethod 'render-map-generic' for dispatch value: null

    use pr-str instead of returning a map

spoke with cognitect; no news yet
