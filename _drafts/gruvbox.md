---
title: Switching from solarized to gruvbox
labels: [review]
tags: [solarized, gruvbox, blue light, fatigue, sleep]
---

Ever since 2012, I've been using
[solarized dark](https://github.com/altercation/solarized) for everything I can
possibly configure. From my web browser to my terminal, and everything in
between, I was a solarized user. Only within the past month did that change and
herein lies why.

### Eye strain
I was experiencing regular eye strain, especially at night, even using solarized
dark and having a low monitor brightness. I use a large font size (large enough
for people to comment on it regularly) and, as of my recent tests, I have at
least 20/20 sight and no known ocular issues.

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

<div style="display:flex">
  {% asset gruvbox/gruvbox.png
           alt:"gruvbox"
           style="flex:50%;width:50%;padding:2px;" %}
  {% asset gruvbox/solarized.png
           alt:"solarized"
           style="flex:50%;width:50%;padding:2px" %}
</div>

### Adopting gruvbox everywhere
gruvbox itself was originally made as just a Vim colorscheme. In its [official
git repository](https://github.com/morhetz/gruvbox), you won't find support for any
other programs. However, there is a
[gruvbox-contrib](https://github.com/morhetz/gruvbox-contrib) repository which
has support for all sorts of themes for editors, shells, and GUI programs. I'm
using the following:

* [Vim colorscheme](https://github.com/morhetz/gruvbox)
* Vim [airline](https://github.com/vim-airline/vim-airline) theme
* [Firefox tab theme](https://addons.mozilla.org/en-US/thunderbird/addon/gruvbox-dark-medium/)
* [Firefox userstyle](https://userstyles.org/styles/137214/gruvbox-dark-everywhere-global-dark-style)
* [dmenu colors](https://www.reddit.com/r/i3wm/comments/78dtn7/how_to_change_dmenus_default_colors/)
* [i3lock colors](https://github.com/PandorasFox/i3lock-color)
* [tty colors](https://archive.fo/QSYHd)
* manual i3wm colors 
* manual [hsetroot](https://aur.archlinux.org/packages/hsetroot) color

### Further blue light reduction
To take things a step further, I also installed
[Redshift](http://jonls.dk/redshift/), which globally affects the warmth of the
screen's colors based on the time of day. That is, as the sun goes down,
Redshift will gradually make the screen have warmer colors, with the least
amount of blue at night. Redshift is conveniently in the official Arch
repositories and it works out of the box. I just added the following to my
`~/.xinitrc`:

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
a definite win. I'd also note that gruvbox hasn't seemed any more difficult to
view than solarized during the day as well.

Surprisingly, Redshift works well even while playing games on Steam. While
playing Rocket League at night, for example, Redshift warms up so much of the
blue that it's shocking when I temporarily disable it to compare.

As for the remaining eye strain, perhaps it's best to just finish computing
earlier at night and schedule more time for reading.
