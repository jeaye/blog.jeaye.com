---
title: Shave 20% off your optimized ClojureScript
categories: [clojurescript, tutorial]
tags: [clojure, clojurescript, minify, optimize, javascript, tutorial]
---

[ClojureScript](https://github.com/clojure/clojurescript) uses the [Google
Closure](https://developers.google.com/closure/?csw=1) compiler, which not only
mangles and minifies code, it also inlines functions and removes dead code.
Still, every extra KB in your application is distributed to every client who
wants to use it. So how can we make it even smaller?

When looking to shrink the client-side source for
[safepaste](https://safepaste.org/), a security-conscious paste site, I looked a
bit outside the ClojureScript box and found a [Node.js](https://nodejs.org/en/)
plugin called [uglify-js](https://github.com/mishoo/UglifyJS2). Among a myriad
of features, uglify-js also contains its own mangler, optimizer, and dead code
remover. Much to my surprise, this optimizer works wonders, even on
Closure-optimized ClojureScript code.

### Installation

Assuming you have Node.js installed, uglify-js can be installed in the current
directory with npm.

```bash
$ npm install uglify-js
```

### Running

Once installed, uglify-js can be used directly on some JS source, whether it's
compiled ClojureScript or a third party JS library (or both).

```bash
$ ./node_modules/uglify-js/uglifyjs --screw-ie8 -c -m -- main.js
```

It contains a slew of parameters, many with a number of their own options, but
the above will get you as far as 20%, in my tests, on already-optimized
ClojureScript code.

### Use cases

Two primary use cases for bringing in uglify-js are apparent to me:

1. Minifying third party JS libraries which preface your optimized CLJS
2. Further minifying your optimized CLJS to shave off even more fat

The good news: you can have them both!

### Integrating into boot

For those who've migrated to [boot](https://github.com/boot-clj/boot), a build
framework for Clojure, here's a
[task](https://github.com/boot-clj/boot/wiki/Tasks) which will minify your
project's `main.js` into a `main.min.js`. It handles installing uglify-js,
minifying, and it falls back to not copying if npm isn't installed.

```clojure
(deftask minify
  "Minify the compiled JS"
  []
  (fn [next-task]
    (fn [fileset]
      (let [tmp (tmp-dir!)
            old-file (tmp-get fileset "js/main.js")
            old-file-path (-> old-file tmp-file .getPath)
            new-file (io/file tmp "js/main.min.js")
            new-file-path (.getPath new-file)
            node-modules "./node_modules/uglify-js"]
        (try
          (io/make-parents new-file)
          (println)
          (when (not (fs/exists? node-modules))
            (println "Installing uglify-js...")
            (shell/sh "npm" "install" "uglify-js"))

          (println "Minifying JS...")
          (shell/sh (str node-modules "/bin/uglifyjs")
                    old-file-path
                    "--screw-ie8"
                    "-c" "-m"
                    "-o" new-file-path)

          (let [original-size (fs/size old-file-path)
                new-size (fs/size new-file-path)]
            (println
              (format "Shaved off %.2f%%\n"
                      (float (* 100 (- 1 (/ new-size original-size)))))))
          (catch Exception _
            (println "npm isn't working; not minifying...")
            (fs/copy old-file-path new-file-path)))
        (next-task (-> fileset
                       (add-resource tmp)
                       (rm [old-file])
                       commit!))))))
```

Add the task definition to your `build.boot`, call it in your `dev` or `build`
tasks after the `cljs` task, and reap the benefits ([example](https://github.com/jeaye/safepaste/blob/master/build.boot#L93)). Be sure to check that your
HTML is including the minified version of the JS! The task will boast its
success upon running.

```text
2016-02-16 17:52:03.094:INFO::main: Logging initialized @4313ms
Compiling ClojureScript...
• js/main.js

Minifying JS...
Shaved off 19.35%

Compiling 1/1 safepaste.core...
2016-02-16 17:52:32.400:INFO::clojure-agent-send-off-pool-0: Logging initialized @33619ms
Writing pom.xml and pom.properties...
Adding uberjar entries...
Writing safepaste.jar...
```

**NOTE:** safepaste is licensed under a GPL-compatible [strict copyleft
license](https://github.com/jeaye/safepaste/blob/master/LICENSE). For your
convenience, I dual license this specific boot task under the more permissive
[MIT](https://opensource.org/licenses/MIT) license as well.

### In combination with gzipping

In hopes of shaving off even more fat, you can use some
[ring](https://github.com/ring-clojure/ring) middleware, like
[ring-gzip](https://github.com/bertrandk/ring-gzip), to serve your content
zipped. Fortunately, the gains of uglify-js are still visible in the gzipped
version, sitting at nearly 10% smaller than the gzipped original source.

### Alternatives

To boot users: you're out of luck. With [leiningen](http://leiningen.org/),
however, there is
[lein-asset-minifier](https://github.com/yogthos/lein-asset-minifier).  For
those interested, I've found that
[boot-cljsjs](https://github.com/cljsjs/boot-cljsjs) is using
lein-asset-minifier within a boot POD. The source can be found
[here](https://github.com/cljsjs/boot-cljsjs/blob/master/src/cljsjs/boot_cljsjs/packaging.clj#L134).

Based on my research, uglify-js is the front-runner in the minification game.
The "impurity" of bringing in npm for the job is entirely worthwhile for me,
considering the palpable gains.
