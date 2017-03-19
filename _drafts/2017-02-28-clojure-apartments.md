---
title: Finding an apartment with Clojure
tags: [clojure, apartment, irc, bot, sf, padwatch, apartment-finder]
---

Finding a reasonably-priced apartment in the Bay Area can be a stressful job.
After factoring in the pressure of an expiring lease, making a poor decision can
be even easier. One approach to weeding out the influx of duplicated, spammy,
and unwanted postings is to use a bot and a set of filters. Such a bot could
crawl various apartment listing sites, match all listings against your filters,
and report to you in whichever format you prefer: email, HipChat, IRC, RSS, etc.
Such a bot may look something like this.

### Existing bots
Arguably the most well-known apartment finding bot was created and documented by
Vik Paruchuri [here](https://www.dataquest.io/blog/apartment-finding-slackbot/).
It takes a very similar approach to what I've done, but uses imperative Python
and Slack. For those interested in researching such a both in Python, that'd be
a great resource. For my research, a bot in Clojure would prove to be more fun
to write.

### Padwatch
[Padwatch](https://github.com/jeaye/padwatch) is an apartment finding bot
written in Clojure, which is designed to work with
[Craigslist](https://craigslist.org/) and [Zillow](https://www.zillow.com/).
Both sources provide HTML content which follows specific patterns and is
"scrapable" in an automated fashion. The key behind the logic for doing web
scraping in Clojure is [Enlive](https://github.com/cgrand/enlive); it's superb
for performing queries on HTML data.

#### Example usage of Enlive
Let's say the goal is to pull out some Craigslist apartment information. It
would be possible to use the following to download and parse the HTML into a
Clojure data structure:

```clojure
(def html-data (-> "https://stockton.craigslist.org/search/apa?max_price=3000"
                   java.net.URL.
                   enlive/html-resource))
```

From there, it's possible to make queries on that data. By inspecting the HTML
in a browser, it's clear that each apartment listing is in a `<p>` tag and has a
class of `result-info`. It's possible then, with Enlive, to pull out all
entities which match that pattern:

```clojure
; Pull out just the rows of results from all of the HTML
(defn select-rows [html-data]
  (enlive/select html-data [:p.result-info]))

(def rows (select-rows html-data))
```

After that selection, `rows` is just a Clojure [vector](https://clojure.org/reference/data_structures#Vectors), where each element represents the contents of the matched `<p>` entity. Now, the HTML of a given row contains something like this:

```html
<!-- Note, here's the :p.result-info referenced from above. -->
<p class="result-info">
  <span class="icon icon-star" role="button" title="save this post in your favorites list">
    <span class="screen-reader-text">favorite this post</span>
  </span>

  <!-- There's information here about the post date. -->
  <time class="result-date" datetime="2016-03-18 12:26" title="Mon 07 Mar 12:22:08 PM">Mar 07</time>

  <!-- This is a link to the page specifically for this listing, as well as its street address. -->
  <a href="/apa/3299094122.html" data-id="3299094122" class="result-title hdrlnk">1672 Hidden alley place</a>

  <!-- Herein lies the price, bedroom/bath count, and neighborhood. -->
  <span class="result-meta">
    <span class="result-price">$2200</span>
    <span class="housing"> 5br - </span>
    <span class="result-hood"> (sacramento)</span>
    <span class="result-tags">
      pic
      <span class="maptag" data-pid="3299094122">map</span>
    </span>
    <span class="banish icon icon-trash" role="button">
      <span class="screen-reader-text">hide this posting</span>
    </span>
    <span class="unbanish icon icon-trash red" role="button" aria-hidden="true"></span>
    <a href="#" class="restore-link">
      <span class="restore-narrow-text">restore</span>
      <span class="restore-wide-text">restore this posting</span>
    </a>
  </span>
</p>
```

To pull out that data into our row data, it's possible to do the following:

```clojure
; Helper to pull out the first match of an Enlive select
(def select-first (comp first enlive/select))

; Take in a single row and a map onto which to assoc the extracted date 
(defn row-post-date [row-data row]
  (let [post-date (-> (select-first row-data [:time]) :attrs :datetime)]
    (assoc row
           :post-date post-date)))

(row-post-date (first rows) {}) ; possible output: {:post-date "2016-03-18 12:26"}

; Same format as above, but assoc in the row's price, if it's valid
(defn row-price [row-data row]
  (let [price-str (-> (select-first row-data [:span.result-price])
                      :content
                      first)
        valid? (re-matches #"\$\d+" (or price-str ""))
        price (when valid?
                (Integer/parseInt (subs price-str 1)))]
    (assoc row
           :price price)))

(row-price (first rows) {}) ; possible output: {:price 2300}
```

As is hopefully quite clear, with a number of
[pure](https://en.wikipedia.org/wiki/Pure_function), concise functions, it's
possible to extract a great deal of information about a given apartment listing.
The benefit of having these functions be individual and pure is that they're
both composable and easy to debug/reason about. That is, a function like
`row-post-date` has the simple task of selecting some data and transforming some
other data before returning it. The reader of the function doesn't need to worry
about global state, which may be mutated, affecting the result of the function.
The reader also needn't worry about thread safety, since these pure functions
are using Clojure's persistent, immutable data structures. This is the benefit
of [functional programming](http://www.braveclojure.com/functional-programming/)
with Clojure.

By combining those functions together, in a reduction, it's straightforward to
build up a model of a given listing.

```clojure
(reduce #(when %1
           (%2 rows %1))
        {} ; Starting with an empty map
        [row-link row-post-date row-price row-where]) ; All of the extractors

; Example simulation of data:
; 1. Reduce calls the first extractor with the empty map
(row-link {})
  => {:link "http://craigslist.com/foo/blah"} ; output

; 2. The result of that is then collected and the next extractor is called
(row-post-date {:link "http://craigslist.com/foo/blah"})
  => {:link "http://craigslist.com/foo/blah"
      :post-date "Feb 2 of the 5th ice age"}

; 3. Rinse and repeat
(row-price {:link "http://craigslist.com/foo/blah"
            :post-date "Feb 2 of the 5th ice age"})
  => {:link "http://craigslist.com/foo/blah"
      :post-date "Feb 2 of the 5th ice age"
      :price 2300}

(row-where {:link "http://craigslist.com/foo/blah"
            :post-date "Feb 2 of the 5th ice age"
            :price 2300})
  => {:link "http://craigslist.com/foo/blah"
      :post-date "Feb 2 of the 5th ice age"
      :price 2300
      :where "sacramento"}

; The last result is the return value of the reduction. It's the map which
; describes the whole row, based on the extractors. It's the apartment data!
```

#### Reporting the data
For easy IRC access in Clojure, it's likely you'll turn to the late Raynes'
[irclj](https://github.com/Raynes/irclj). The API is minimal and can be wrapped
with just a few lines.

```clojure
(def nick "padwatch")
(def channel "#padwatch")

(def connection (atom nil))

; By default, logs go to stdout; use this to quiet them
(defn eat-log [& args]
  (comment pprint args))

(defn disconnect! []
  (when @connection
    (swap! connection irc/kill)))

(defn connect! []
  (disconnect!)
  (reset! connection (irc/connect "irc.freenode.net"
                                  6667 nick
                                  :callbacks {:raw-log eat-log}))
  (irc/join @connection channel))

(defn message! [msg]
  (irc/message @connection channel msg))
```

From there, reporting listings as they come in should be no problem. To make the
output more terse, some URL shortening can specific formatting could be applied.

```clojure
; Take a url and return the shortened one, if possible
(defn shorten-url [url]
  (when url
    (try
      (slurp (str "http://tinyurl.com/api-create.php?url=" url))
      (catch Throwable _ ; tinyurl can time out; just skip the shortening
        url))))

; Easily pull a specific list of keys from a map
(defn extract [m ks]
  (reduce #(assoc %1 %2 (m %2)) {} ks))

(defn message-row! [row-info]
  (let [useful (merge (util/extract row-info [:where :style :price :sqft])
                      {:url (-> row-info :url shorten-url)
                       :walkscore (-> (:walkscore row-info)
                                      (update :url shorten-url)
                                      (dissoc :description))})]
    (irc/message @connection channel (pr-str useful))))
```

### A note on terms of service
Craigslist, Zillow, and likely most other apartment listing websites have
listed, in their terms of service (to which you agree by using their service),
that scraping their data with bots is not permitted. You need to know this.

### Summary
To me, this was a perfect use case for Clojure: data in, data out. Lots of pure
transformations, querying of deep data structures, and the occasional side
effect (writing to the db to minimize duplicates, reporting listings to IRC). If
you're interested in learning more about Clojure, I recommend, first and
foremost, you read through [Brave Clojure](http://www.braveclojure.com/).
