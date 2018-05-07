---
title: Switching from solarized to gruvbox
labels: [review]
tags: [solarized, gruvbox, blue light, fatigue, sleep]
---

Ever since 2012, I've been using
[solarized dark](https://github.com/altercation/solarized) for everything I can
possibly configure. From my window manager to my web browser, terminal, and
everything in between, I was a solarized user. Only within the past month did
that change and herein lies why.

### Eye strain
I was experiencing regular eye strain, especially at night, even using solarized
dark and having a low monitor brightness. I use a large font size (large enough
for people to comment on it regularly) and, as of my recent tests, I have at
least 20/20 visual and no known ocular issues.

### Hypothesis
After a bit of research, it turns out there's a lot of documentation on the
affects of blue light on the eyes and sleep cycle, specifically when it's viewed
at night ([for
example](https://en.wikipedia.org/wiki/Effects_of_blue_light_technology)). Could
it be that the deep blue background I use, due to solarized dark, is
exacerbating the problem?

### Alternatives to solarized
There are too many to list, but one which caught my eye was
[gruvbox](https://github.com/morhetz/gruvbox). Specifically, gruvbox has a
pretty warm palette and minimal emphasis on blue, which is quite a change from
my old setup. Here are some comparison images.

TODO


### Further blue light reduction
To take things a step further, I also installed
[Redshift](http://jonls.dk/redshift/), which globally affects the warmth of the
screen's colors based on the time of day. That is, as the sun goes down,
Redshift will gradually make the screen have warmer colors, with the least
amount of blue at night. Redshift is conveniently in the official Arch repos and
it works out of the box. I just added the following to me `~/.xinitrc`:

```bash
# Remove blue light at night
redshift-gtk &
```

### Verdict
Has gruvbox with Redshift actually helped? When I'm using the computer,
especially at night, my eyes do still feel strained. However, if I disable
Redshift and switch solarized dark back on, it's very tough to look at the
screen again! There's such a stark difference between looking at gruvbox +
Redshift and looking at solarized dark. With that said, I consider this decision
a definite win.

As for the remaining eye strain, perhaps it's best to just finish computing
earlier at night and starting my book reading earlier.

* https://github.com/morhetz/gruvbox
* https://github.com/morhetz/gruvbox-contrib
* https://addons.mozilla.org/en-US/thunderbird/addon/gruvbox-dark-medium/
* https://userstyles.org/styles/137214/gruvbox-dark-everywhere-global-dark-style
* https://archive.fo/QSYHd
