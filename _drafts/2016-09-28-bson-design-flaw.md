---
title: BSON and the design flaw
tags: [bson, flaw, array, json, rant]
---

In situations where [JSON](http://json.org/)'s convenient, human-readable syntax
results in noticeably slower parse times and/or increased memory usage, one
might look for the more compact [BSON](http://bsonspec.org/). Aside from sitting
smaller in memory, BSON libraries can more easily provide non-owning solutions,
which allow them to reference a read-only bit of BSON data directly, rather than
own a copy internally. This has the big selling point of allowing [memory-mapped
files](https://en.wikipedia.org/wiki/Memory-mapped_file) to be used as a BSON
backend, while all operations on the immutable BSON require no copying or
ownership. Unfortunately, there exists an under-documented design flaw in BSON
which renders it incompatible with standard, and common, JSON.

#### Use case
While porting some JSON work to BSON, it became clear that the API provided by
the BSON library lacked support for creating top-level arrays. That is, this is
valid JSON:

```json
[1, "kitty", "foo"]
```

Unfortunately, after some more research, this doesn't map to valid BSON. The
BSON mailing list covered this in three threads:

* On [3/19/10](https://groups.google.com/forum/#!searchin/bson/array$20root|sort:relevance/bson/b7Jav8Xg2vo/paZvbDHP50AJ), it was said: *"i think there should be a rev of bson at some point, and we should all participate in what changes, and we should be very careful what changes before making any change"*
* On [11/14/10](https://groups.google.com/forum/#!searchin/bson/array$20root%7Csort:relevance/bson/VHaO42PPMGc/l-ZqIMcLpfMJ), this was brought up again: *"perhaps this is a design bug"*
* Finally, on [4/13/11](https://groups.google.com/forum/#!msg/bson/Y6gN4Btd6us/H_F-nilcXiAJ;context-place=forum/bson), it was resurfaced: *"yes.  probably was an oversight long ago."*

Each of the threads references a to-be-announced BSON 2.0; since it's been
nearly seven years, this probably isn't happening. Either way, it's crucial to
note that your **data may not be representable in BSON without changes.**

#### Mitigation
