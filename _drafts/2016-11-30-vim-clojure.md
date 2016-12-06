---
title: A Clojure + Vim setup
tags: [clojure, programming, vim, plugin]
---

Those in Emacs land need not worry about excellent Lisp and REPL support. Here
in Vim land, the ground is less certain. There have been a myriad of attempts to
provide Paredit-like editing and SLIME-like evaluating to those who edit
modally. Here's a contemporary look at helping Vim provide the expected slurpage,
barfage, evaluation, and more.

*What's slurping and barfing...? See [here](http://usevim.com/2015/02/25/clojure/).*

### The lineup
The key plugins I use are listed below. As mentioned in a [previous
post](https://blog.jeaye.com/2015/12/31/vim-qt/), I'm running
[Vim-Qt](https://bitbucket.org/equalsraf/vim-qt/wiki/Home) and my Vim configs
are [here](https://github.com/jeaye/vimrc).

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

vim-sexp just works, when it comes to repeating, partially due to its
compatibility with tpope's `vim-repeat`. It also is less strict than Paredit
when it comes to manually unbalancing parens, which can annoyingly get in the
way in non-trivial use cases. Paredit's rigidity, in that sense, also led to
situations where parens were left unbalanced by an edit, but Paredit thought
otherwise and wouldn't allow one to easily correct the issue.

vim-sexp's key flaw appears to be that its bindings are unapproachable. tpope
saved the day, again, with sarcasm and vim-sexp-mappings-for-regular-people.
Take a look at the
[README](https://github.com/tpope/vim-sexp-mappings-for-regular-people) for an
example of how minimal and clean the mappings have become. Combined with
vim-surround, as Venantius said, Vim becomes a formidable s-expr wrangler.

### Pitfalls to dodge
#### When using vim-fireplace, no `.nrepl-port` file is found
If you need to manually `:Connect` and type in your nREPL port, there's
something wrong. I've found that `lein repl` creates the appropriate
`.nrepl-port` file, while `lein trampoline repl` does not. I've created an
[issue](https://github.com/technomancy/leiningen/issues/2224) on Leiningen's
Github; we'll see if this is a bug or something intentional.
