---
title: A Clojure + Vim setup
tags: [clojure, programming, vim, plugin]
---

Those in Emacs land need not worry about excellent Lisp and REPL support. Here
in Vim land, the ground is less certain. There have been a myriad of attempts to
provide paredit-like editing and slime-like evaluating to those who edit
modally. Here's a contemporary look at helping Vim provide the expected slurpage,
barfage, evaluation, and more.

### The lineup
The key plugins I use are listed below. As mentioned in a [previous
post](https://blog.jeaye.com/2015/12/31/vim-qt/), I'm running
[Vim-Qt](https://bitbucket.org/equalsraf/vim-qt/wiki/Home).

* [guns/vim-sexp](https://github.com/guns/vim-sexp)
* [tpope/vim-sexp-mappings-for-regular-people](https://github.com/tpope/vim-sexp-mappings-for-regular-people)
* [tpope/vim-surround](https://github.com/tpope/vim-surround)
* [luochen1990/rainbow](https://github.com/luochen1990/rainbow)
* [tpope/vim-fireplace](https://github.com/tpope/vim-fireplace)
* [tpope/vim-salve](https://github.com/tpope/vim-salve)

[Venantius](https://venanti.us/) has done an excellent job, in [his
blog](http://blog.venanti.us/clojure-vim/), covering the ins and outs of most of
these plugins; I think that his post is certainly worth reading before
continuing here.

### What's new?
The big difference between our setups is the change from
[Paredit.vim](http://www.vim.org/scripts/script.php?script_id=3998) to vim-sexp.
vim-sexp showed up a couple of years ago and filled in a hole which was sorely
left gaping: repeatability. Paredit.vim suffers a fatal flaw, in that it rebinds
`.` to do its own repeating and it breaks core Vim functionality. Depending on
your workflow, this is a deal breaker. If you ever user `.` to not retype what
you just typed, this is a deal breaker.

lein trampoline repl

http://usevim.com/2015/02/25/clojure/
