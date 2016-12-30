---
title: Continuous code coverage in Clojure
tags: [clojure, programming, code, coverage, cloverage, codecov]
---

For those building Clojure applications backed by tests, you may be wondering
just how broad, or deep, your test coverage is. Fortunately, automated coverage
analysis can be integrated in a handful of minutes using
[cloverage](https://github.com/cloverage/cloverage) and
[codecov](https://codecov.io/).

### What is code coverage?
*The term test coverage used in the context of programming / software
engineering, refers to measuring how much a software program has been exercised
by tests.* ([Fault Coverage](https://en.wikipedia.org/wiki/Fault_coverage)).
With cloverage, you can analyze the coverage of your
[clojure.test](https://clojure.github.io/clojure/clojure.test-api.html) or
[Midie](https://github.com/marick/Midje) tests.

### Trying out cloverage
You can add cloverage to your `~/.lein` plugins, but, in order to allow anyone
who clones your repo to run coverage analysis, it's recommended to instead place
the following inside your `project.clj` plugins.

```clojure
[lein-cloverage "1.0.9"]
```

*Note: cloverage may have updated since the time of writing, so double check
the latest version on [clojars](https://clojars.org/lein-cloverage).*

Now that cloverage is specified, you can have cloverage run by simply issuing:

```
$ lein cloverage
```

For Midje users, specify `--runner :midje` as well.


### Examining the output
By default cloverage will run all of your tests and generate an HTML output at
`target/coverage/index.html`. Open that up with your favorite browser and you'll
see something like this:

<div style="text-align:center">
<a href="{{ site.blog_url }}/img/clojure-code-coverage/cloverage-index.png" target="_blank">
<img alt="cloverage index screen shot"
     src="{{ site.blog_url }}/img/clojure-code-coverage/cloverage-index.png" width="66%" />
</a>
</div>

This is the output from the first run of cloverage on
[jank](http://jank-lang.org/). From this, we can see that there was reasonable
coverage for the parsing and type checking tests, but it clearly had no tests
for interpreting and codegen. It's possible to get a more detailed view of any
of these files by clicking one.

<div style="text-align:center">
<a href="{{ site.blog_url }}/img/clojure-code-coverage/cloverage-detailed.png" target="_blank">
<img alt="cloverage index screen shot"
     src="{{ site.blog_url }}/img/clojure-code-coverage/cloverage-detailed.png" width="66%" />
</a>
</div>

After clicking on a specific file, it's possible to see a line-by-line breakdown
of the coverage. In the above image, it's clear that there are no tests which
cover adding explicit returns for macro definition, since that code was never
hit when cloverage ran jank's test suite.

### Running it continuously
Manually running cloverage is great, but something like this should be running
with each push to Github. This is where [codecov](https://codecov.io/) comes in.
Like Github, codecov is free for an unlimited number of
[FOSS](https://en.wikipedia.org/wiki/Free_and_open-source_software) projects.
Sign up using your Github session and add one of your Clojure projects. The
following assumes that you already have continuous testing using
[travis-ci](https://travis-ci.com/).

Add the following to your `.travis.yml`

```yaml
after_success:
- lein cloverage --codecov
- bash <(curl -s https://codecov.io/bash) -f target/coverage/codecov.json
```

### Adding a readme badge
If you'd like, you can add a codecov badge to your `README.md`, like so:

```markdown
[![codecov](https://codecov.io/gh/jeaye/jank/branch/master/graph/badge.svg)](https://codecov.io/gh/USERNAME/PROJECT-NAME)
```

### Ok, then?
No, seriously, that's it. Whenever you push and the build succeeds, travis-ci
will run your coverage analysis and output the results in a specific codecov
format. Those results will then just be uploaded to codecov, which already knows
and trusts travis-ci servers, and your project's codecov page will be update
shortly thereafter.
