---
title: Continuous test coverage in Clojure
categories: [clojure, tutorial]
tags: [clojure, programming, code, coverage, cloverage, codecov]
---

For those building Clojure applications backed by tests, you may be wondering
just how broad, or deep, your test coverage is. Fortunately, automated coverage
analysis can be integrated in a handful of minutes using
[cloverage](https://github.com/cloverage/cloverage) and
[codecov](https://codecov.io/).

### What is test coverage?
*The term test coverage used in the context of programming / software
engineering, refers to measuring how much a software program has been exercised
by tests.* ([Fault Coverage](https://en.wikipedia.org/wiki/Fault_coverage)).
With cloverage, you can analyze the coverage of your
[clojure.test](https://clojure.github.io/clojure/clojure.test-api.html) or
[Midje](https://github.com/marick/Midje) tests.

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
By default, cloverage will run all of your tests and generate an HTML output at
`target/coverage/index.html`. Open that up with your favorite browser and you'll
see something like this:

<figure>
<a href="{{ site.blog_url }}/img/clojure-test-coverage/cloverage-index.png" target="_blank">
<img alt="cloverage index screen shot"
     src="{{ site.blog_url }}/img/clojure-test-coverage/cloverage-index.png"/>
</a>
<figcaption>
This is the output from the first run of cloverage on <a
href="http://jank-lang.org/">jank</a>. From this, we can see that there was good
coverage for the parsing and type checking tests, reasonable coverage for
interpreting, but it clearly had no tests for codegen. It's possible to get a
more detailed view of any of these files by clicking one.
</figcaption>
</figure>

<figure>
<a href="{{ site.blog_url }}/img/clojure-test-coverage/cloverage-detailed.png" target="_blank">
<img alt="cloverage index screen shot"
     src="{{ site.blog_url }}/img/clojure-test-coverage/cloverage-detailed.png" />
</a>
<figcaption>
After clicking on a specific file, it's possible to see a line-by-line breakdown
of the coverage. In the above image, it's clear that there are no tests which
cover adding explicit returns for macro definition, since that code was never
hit when cloverage ran jank's test suite.
</figcaption>
</figure>

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

### Adding a README badge
If you'd like, you can add a codecov badge to your `README.md`, like so:

```markdown
[![codecov](https://codecov.io/gh/USERNAME/PROJECT-NAME/branch/master/graph/badge.svg)]
 (https://codecov.io/gh/USERNAME/PROJECT-NAME)
```

### Ok, then?
No, seriously, that's it. Whenever you push and the build succeeds, travis-ci
will run your coverage analysis and output the results in a specific codecov
format. Those results will then just be uploaded to codecov, which already knows
and trusts travis-ci servers, and your project's codecov page will be update
shortly thereafter. Have a look around the codecov site, which provides a
similar view into your source, with various graphs and metrics.


### Quick note about test coverage
It's worthwhile to note that 100% test coverage probably isn't worth the effort.
Furthermore, test coverage doesn't mean that your tests are any good and that
they are representative of the inputs and behaviors your application will see in
the wild. Especially in Clojure, so much of our programs rely on the data, not
the code.

Assuming that's been noted, the coverage analysis is superb for
pointing out dead code, missed corner cases, and other areas which don't see
much love in your test suite. Your argument parsing, for example, or codegen in
the case of jank. By putting a coverage badge on your README, you're entering a
silent contract to improve your coverage with quality tests.
