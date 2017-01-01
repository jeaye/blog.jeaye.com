---
title: Real artists ship
tags: [rant, programming]
---

I want to tackle an issue which seems prevalent in the modern software
engineering industry. The idea, laid down by [Steve Jobs](TODO), is that "real
artists ship" and everyone else is forgotten. What does it mean to be a "real
artist," and what does it mean to "ship" as one? I think what Jobs meant when he
said it and what many others mean when they parrot it may be quite different.
It's become a facade, analogous to
[YOLO](http://www.urbandictionary.com/define.php?term=Yolo), intended to cover
one's tracks of poor engineering practices, lack of tool understanding, and lack
of concern for the success of the product beyond delivery.

### It's a joke
Many people do say "real artists ship" as joke, when knowingly tolerating some
poor practice. The problem worth pointing out is that, while this is a joke,
it's actually masking the underlying issue in unsettling humor. It's become
affordable, in engineering social circles and development teams, to subvert good
practice in favor of reaching deadlines -- and here's the kicker -- with no
intention of returning to the code to refactor.

Furthermore, it's become an attack against those who do care about software
quality. In this form, it's not a joke at all, but a claim from a high horse
that shipped products are not polished products, or stable products, or secure
products. A lunch-time conversation between two equal-ranked devs may go like
this:

Sally: *"Did you get tests written for the new notification system?"*

Heather: *"No, I needed to get it out the door."*

Sally: *"Yeah, that dealine was tight. Do you plan on getting the tests written
before the next sprint?"*

Heather: *"No, I don't think they're important. The code works and it's live."*

Sally: *"It is important, since it's such a core system; we can verify all parts
of it behave as expected, and protect against regressions, with tests."*

Heather: *"If we do it your way, Sally, we never ship. Real artists ship."*

### The philosophy
Like so many other aspects in this world, software practices are treated as
black and white. You're either apparently a real artist, who ships, or you're
someone who cares about the quality of your product and you never ship. Surely,
this is absurd.

#### Testing
Having software tests means one thing, specifically: you care, or are required
to care, about software quality. Do companies with automated tests actually ship
code? Let's take a look at the big four.

1. Google? - [Of
   course](https://testing.googleblog.com/2011/01/how-google-tests-software.html)
2. Amazon? - 
   [Yep](http://www.zdnet.com/article/how-amazon-handles-a-new-software-deployment-every-second/)
3. Facebook? - [Absolutely](https://youtu.be/OJ94KqmsxiI?t=1393)
4. Microsoft? - 
   [You bet](https://blogs.msdn.microsoft.com/microsoft_press/2009/02/13/new-book-how-we-test-software-at-microsoft/)

Ok, let's try smaller companies.

1. [CircleCI](https://circleci.com/blog/rewriting-your-test-suite-in-clojure-in-24-hours/)
2. [AirBnB](http://airbnb.io/enzyme/)
3. [Uber](https://eng.uber.com/tech-stack-part-one/)
4. [Github](http://githubengineering.com/move-fast/)
5. [Assertible](https://assertible.com/blog/test-every-single-api-deployment)

What about some of the big open source projects?

1. [Linux](https://linux-test-project.github.io/)
2. [Krita](https://community.kde.org/Krita/Docs/Unittests_in_Krita)
3. [Firefox](https://developer.mozilla.org/en-US/docs/Mozilla/QA/Automated_testing)
4. [React.js](https://facebook.github.io/react/docs/test-utils.html)
5. [Emacs](https://www.emacswiki.org/emacs/UnitTesting)
6. [NeoVim](https://github.com/neovim/neovim/wiki/Unit-tests)

My experience is primarily in game development, where software testing is
apparently far less common. Imperative programming exacerbates this
problem, making functions harder to test, but games, and especially game
engines, are just as testable as anything else. Again, some examples.

1. [UnrealEngine](https://docs.unrealengine.com/latest/INT/Programming/Automation/index.html)
2. [Unity3D](https://unity3d.com/unity/qa/test-suites)
3. [Crytek](http://www.crytek.com/cryengine/cryengine3/presentations/aaa-automated-testing-for-aaa-games)
4. [RIOT](https://engineering.riotgames.com/news/automated-testing-league-legends)
5. [CCP/Eve Online](https://community.eveonline.com/news/dev-blogs/eve-probe/)

Software testing is not a religion. Too much of it and you may not meet your
deadline. Too little of it and you may not meet many users. If you have to ship
without testing, in order to get your Apple featuring, or similar, fine. Will
you test next sprint? Will you ensure there are no regressions in functionality
or performance?

Related [Gamasutra
article](http://www.gamasutra.com/view/feature/130682/automated_tests_and_continuous_.php).

#### Refactoring

#### Learning

### The damage

### What Jobs really meant

### What "real artists" may actually be
