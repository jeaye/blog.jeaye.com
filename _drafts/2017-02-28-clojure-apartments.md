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

Talk about:
  law for infinite set (ignore first third to get price)
  terms of service
