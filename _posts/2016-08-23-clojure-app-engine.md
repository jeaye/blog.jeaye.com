---
title: Running Clojure on Google App Engine
tags: [clojure, programming, appengine, google, tutorial]
---

Clojure excels at pure transformations of persistent data. One area well-suited
for this is a stateless server which transforms data between the client and the
datastore. For distributed server development in Clojure, we already have
[Onyx](http://www.onyxplatform.org/), as well as [wrappers for
Mesos](https://github.com/pyr/mesomatic) and others. An apparently less-explored
option is the use of Clojure on Google App Engine, which runs sandboxed
applications in Google-managed data centers while providing automatic scaling.

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
specifically Clojure applications. Its examples are in Java, using Maven, with
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

1. [http://lambda-startup.com/developing-clojure-on-app-engine/](http://lambda-startup.com/developing-clojure-on-app-engine/)
2. [http://flowa.fi/blog/2014/04/25/clojure-gae-howto.html](http://flowa.fi/blog/2014/04/25/clojure-gae-howto.html)

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


* `Compilation failed: No method in multimethod 'print-dup' for dispatch value:
  class org.sonatype.aether.repository.RemoteRepository`

    The solution here is to upgrade lein-ring to 0.9.7; the lambda-startup docs
    are outdated and recommend 0.9.6. I highly recommend
    [lein-ancient](https://github.com/xsc/lein-ancient) for keeping dependencies
    up-to-date.

* `No API environment is registered for this thread`

    This will happen if you try to use datastore from the REPL. Since it can
    only be accessed from one thread, I've only been able to do my datastore
    work from within the program. It's an annoyance, but not as serious of an
    issue as it first seemed.

* `java.lang.ClassNotFoundException:
  com.google.appengine.tools.development.ApiProxyLocalFactory`

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

#### Liberator-specific issues
For those not familiar with Clojure's
[Liberator](https://clojure-liberator.github.io/liberator/) library, I *highly
recommend it*, in conjunction with Compojure. I came across Liberator by reading
[this
post](http://www.flyingmachinestudios.com/programming/building-a-forum-with-clojure-datomic-angular/).
With all of its lovely features, there are some behavior differences I've
noticed between the App Engine development and production servers, when it comes
to Liberator.

* `No method in multimethod 'render-map-generic' for dispatch value: null`

    This occurs when you return a map which contains a nil key from a Liberator
    resource. Use [pr-str](http://clojuredocs.org/clojure.core/pr-str) instead
    of returning a map directly.

* Status 400 when accessing liberator/compojure routes

    Watch your [MIME types](https://en.wikipedia.org/wiki/Media_type)! The App
    Engine + Liberator combo isn't so much the "issue" as Google's front-end
    servers are. If you're lazy, during development, and you're using curl or
    the handy [httpie](https://github.com/jkbrzt/httpie), you may run into this
    issue because you haven't specified an `Accept` header.

    ```bash
    curl -i -H "Accept: application/json" -X POST -d "" "https://project-id.appspot.com/meow?kitty=cat"

    # or...

    http POST "https://project-id.appspot.com/meow?kitty=cat" Accept:application/json
    ```

    While testing, an echo resource proved very useful.

    ```clojure
    (defresource echo
      :media-type-available? (constantly true)
      :method-allowed? (constantly true)
      :handle-ok (partial pr-str)
      :handle-created (partial pr-str))
    ```

#### One-shot deploy script
It's been said, over and over, that a deployment should only take a single
command. For this simple App Engine setup, a bash script will do the trick.
The only change this requires, aside from storing the script adjacent to the
`install-gae` script in the root of the project, is that the `appengine-web.xml`
file is also stored in the root of the project. The project ID, which is to be
kept secret, should be `XXX`; it'll be read from the `gae_project_id`
environment variable and substituted.

For something more complex, consider integrating a custom [leiningen plugin](https://github.com/technomancy/leiningen/blob/stable/doc/PLUGINS.md).

```bash
#!/usr/bin/env bash

set -ue

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$here/install-gae"

function deploy
{
  echo "Building uberwar"
  war=$(lein ring uberwar | egrep "Created .+" | cut -d' ' -f2)

  if [ "x$war" == "x" ];
  then
    echo "Unable to build war"
    return 1
  fi

  tmp=$(mktemp -d /tmp/XXXXXX)
  echo "Exploding"
  pushd "$tmp"
    jar xf "$war"
    if [ -z ${gae_project_id+x} ];
    then
      echo "No gae_project_id set in environment"
      exit 1
    fi
    sed "s/XXX/$gae_project_id/g" < "$here/appengine-web.xml" > WEB-INF/appengine-web.xml

    echo "Uploading"
    "$gae_sdk/bin/appcfg.sh" update .
  popd

  echo "Deployed!"
}
deploy
```

#### Closing thoughts
The biggest issue, once everything's working, is just getting through all that
Java interop. The appeal of something like
[appengine-magic](https://github.com/gcv/appengine-magic) is that so much of the
cruft is hidden away. At the very least, its interface and MIT-licensed
implementation gives us a starting point from which we can clean up our App
Engine code.

Cognitect approached me recently, asking how I'm enjoying Datomic.
Unfortunately, I replied saying it's not being utilized, since it lacks support
for Google Cloud Datastore. I was linked to the [mailing list
thread](https://groups.google.com/forum/#!topic/datomic/M9v1ssUbT9Q/discussion),
where some users have reportedly setup Datomic with Google Cloud SQL. That's
something worth investigating.
