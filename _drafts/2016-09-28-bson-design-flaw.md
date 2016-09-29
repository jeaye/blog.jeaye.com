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
