---
title: BSON and the design flaw
tags: [bson, flaw, array, json, rant]
---

In situations where [JSON](http://json.org/)'s convenient, human-readable syntax
results in noticeably slower parse times and/or increased memory usage, one
might look for the more compact [BSON](http://bsonspec.org/). Aside from sitting
smaller in memory, BSON libraries can more easily provide non-owning solutions,
which allow them to reference a read-only chunk of BSON data directly, rather
than own a copy internally. This has the big selling point of allowing
[memory-mapped files](https://en.wikipedia.org/wiki/Memory-mapped_file) to be
used as a BSON backend, while all operations on the immutable BSON require no
copying or ownership. Unfortunately, there exists an under-documented design
flaw in BSON which renders it incompatible with common, standard JSON.

#### Use case
The issue arises as soon as there are top-level arrays. For example, this is
valid JSON:

```json
[1, "kitty", "foo"]
```

Unfortunately, after some more research, this doesn't map to valid BSON. The
BSON mailing list covered this in three threads:

* On [3/19/10](https://groups.google.com/forum/#!searchin/bson/array$20root%7csort:relevance/bson/b7Jav8Xg2vo/paZvbDHP50AJ), it was said: *"very good point regarding the root document. i think there should be a rev of bson at some point, and we should all participate in what changes, and we should be very careful what changes before making any change"*
* On [11/14/10](https://groups.google.com/forum/#!searchin/bson/array$20root%7Csort:relevance/bson/VHaO42PPMGc/l-ZqIMcLpfMJ), this was brought up again: *"perhaps this is a design bug"*
* Finally, on [4/13/11](https://groups.google.com/forum/#!msg/bson/Y6gN4Btd6us/H_F-nilcXiAJ;context-place=forum/bson), it was resurfaced: *"yes.  probably was an oversight long ago."*

Each of the threads references a to-be-announced BSON 2.0; since it's been
nearly seven years, this probably isn't happening. Either way, it's crucial to
note that your **data may not be representable in BSON without changes.**

#### Mitigation
If the performance gains still compel you to make the switch to BSON, you might
find yourself having to make top-level arrays into nested elements of a
singly-keyed map, perhaps specified with a unique identifier.

```json
{"$array": [1, "kitty", "foo"]}
```

This isn't a show stopper for me, and it may not be for you, but this should
certainly not be swept under the rug. In fact, the official description of BSON
seems a bit unfair, in this regard:

    ... a binary-encoded serialization of JSON-like documents. Like JSON, BSON
    supports the embedding of documents and arrays within other documents
    and arrays.

It's not wrong. You *can* embed documents in arrays. Unfortunately, everything
must be in a document.
