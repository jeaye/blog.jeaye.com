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
For those interested in researching such a both in Python, that'd be a great
resource. For my research, a bot in Clojure would prove to be more fun to write.

### Padwatch
[Padwatch](https://github.com/jeaye/padwatch) is an apartment finding bot
written in Clojure, which is designed to work with Craigslist and Zillow. Both
sources provide HTML content which follows specific patterns and is "scrapeable"
in an automated fashion. The key behind the logic for doing web scraping in
Clojure is [Enlive](https://github.com/cgrand/enlive); it's superb for
performing queries on HTML data.

#### Example usage of Enlive
Let's say the goal is to pull out some Craigslist apartment information. It
would be possible to use the following to download and parse the HTML into a
Clojure data structure:

```clojure
(def html-data (-> "https://stockton.craigslist.org/search/apa?max_price=3000"
                   java.net.URL.
                   enlive/html-resource))
```

From there, it's possible to make queries on that data. For example:

```clojure
; Pull out just the rows of results from all of the HTML
(defn select-rows [html-data]
  (enlive/select html-data [:p.result-info]))

(def rows (select-rows html-data))
```

Now, the HTML of a given row contains something like this:

```html
<span class="icon icon-star" role="button" title="save this post in your favorites list">
  <span class="screen-reader-text">favorite this post</span>
</span>

<time class="result-date" datetime="2016-03-18 12:26" title="Mon 07 Mar 12:22:08 PM">Mar 07</time>
<a href="/apa/3299094122.html" data-id="3299094122" class="result-title hdrlnk">1672 Hidden alley place</a>

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
```

To pull out that data into our row data, it's possible to do the following:

```clojure
; helper
(def select-first (comp first select))

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
By combining those functions together, in a reduction, it's very straightforward
to build up a model of a given listing.

```clojure
(reduce #(when %1
           (%2 rows %1))
        {} ; Starting with an empty map
        [row-link row-post-date row-price row-where]) ; All of the extractors
```

#### Reporting the data
For easy IRC access in Clojure, it's likely you'll turn to the late Raynes'
[irclj](https://github.com/Raynes/irclj). Surely, I did; the API is so simple!

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
  (reduce #(assoc %1 %2 (m %2)) {} keys))

(defn message-row! [row-info]
  (let [useful (merge (util/extract row-info [:where :style :price :sqft])
                      {:url (-> row-info :url shorten-url)
                       :walkscore (-> (:walkscore row-info)
                                      (update :url shorten-url)
                                      (dissoc :description))})]
    (irc/message @connection channel (pr-str useful))))
```

Talk about:
  law for infinite set (ignore first third to get price)
  terms of service
