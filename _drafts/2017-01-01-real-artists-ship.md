---
title: Real artists ship
tags: [rant, programming]
---

I want to tackle an issue which seems prevalent in the modern software
engineering industry. The idea, laid down by [Steve
Jobs](http://www.folklore.org/StoryView.py?story=Real_Artists_Ship.txt), is that
"real artists ship" and everyone else is forgotten. What does it mean to be a
"real artist," and what does it mean to "ship" as one? It's become a facade,
analogous to [YOLO](http://www.urbandictionary.com/define.php?term=Yolo),
intended to cover one's tracks of poor engineering practices, lack of tool
understanding, and lack of concern for the success of the product beyond
delivery.

### It's a joke?
Many people do say "real artists ship" as joke, when knowingly tolerating some
poor practice. The problem worth pointing out is that, while this said in jest,
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
black and white. You're either apparently a "real artist", who ships, or you're
someone who cares about the quality of your product and you never ship. Surely,
this is absurd.

#### Testing
Having software tests means one thing, specifically: you care, or are required
to care, about software quality. Do companies with automated tests actually ship
code? Let's take a look at the big four.

1. [Google](https://testing.googleblog.com/2011/01/how-google-tests-software.html)
2. [Amazon](http://www.zdnet.com/article/how-amazon-handles-a-new-software-deployment-every-second/)
3. [Facebook](https://youtu.be/OJ94KqmsxiI?t=1393)
4. [Microsoft](https://blogs.msdn.microsoft.com/microsoft_press/2009/02/13/new-book-how-we-test-software-at-microsoft/)

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

Clearly, it's entirely possible to have automated tests running continuously,
alongside your typical QA. The best thing about it is, you can still ship! Even
better, you can both ship and iterate more confidently. If you do have to ship
without testing, in order to meet some external deadline, fine. Will you test
next sprint? Will you ensure there are no regressions in functionality or
performance?

No stance on this should be religious; in every aspect, we must be pragmatic.
Too much testing and you may not meet your deadline. Too little of it and you
may not meet many users, or you may struggle to keep them. Build a company
around a foundation of untested code, continue to accrue hundreds of thousands
of lines of it, and then expect stability and performance? That is not sane.

[Related Gamasutra article](http://www.gamasutra.com/view/feature/130682/automated_tests_and_continuous_.php).

#### Refactoring
"Real artists" also seem to not have time to refactor old code. Write it once, get
it done, and ship it. If you're one of those devs who goes back, after cranking
out a new system, and removes duplication, improves API type safety, or adds
more assertions and documentation, you may not be a "real artist". Worse, you may
never ship.

Refactoring code should be thought of as code hygiene. Just as most of us shower
regularly, brush our teeth, and wipe after shitting, we need to clean up our
code. The social norm, it seems, has us hiding from those who don't shower, but
embracing those who skip on the refactoring, anointing them as "real artists".

<figure><figcaption style="font-style: italic;">
"At GitHub we try not to brag about the “shortcuts” we’ve taken over the
years to scale our web application to more than 12 million users. In fact,
we do quite the opposite: we make a conscious effort to study our codebase
looking for systems that can be rewritten to be cleaner, simpler and more
efficient, and we develop tools and workflows that allow us to perform these
rewrites efficiently and reliably." ~ <a href="http://githubengineering.com/move-fast/">Github</a>
</figcaption></figure>

#### Learning
It also seems that "real artists" claim to know all that there is needed to know
for shipping their products. However, there is always room for growth. We should
always be striving to improve our craft. We should always be looking to
modernize our practices. We can greatly benefit from reflecting on our flaws, or
even having our code reviewed by the team. Yet these ideas are not of the real
artist.

The more one observes "real artists," the more it becomes clear that they are
entirely one dimensional. They're built to ship, regardless of parameters, and
will sacrifice anything to do so. Technical debt will accrue without bound and,
after years, the hope to gain a firm grasp of the product's stability and
behavior will be immaterial.

### The damage
The army of "real artists" may have barricaded your workplace. If so, you'll be
met with great reluctance when trying to introduce code reviews, continuous
integration, and modern safety practices. You'll be labeled an extremist for
calling out and proposing fixes for poor tooling, bit-rotten systems, and
haggard practices. You may find solace in some colleagues, but only rigidity on
a department level.

Consider the effect of this behavior on the product. Can you release
continuously? Probably not; getting stable binaries out is a slow chug, so bugs
linger. Are your users frustrated that your software crashes often? That goes
without saying. Is your new-user experience poor because of your degrading
performance? Can you address this without systemic changes? Is your poor
developer tooling hurting the productivity of your devs and significantly
increasing your iteration time?  Is is troubling to on-board new devs, given the
poor documentation and [bus factor](https://en.wikipedia.org/wiki/Bus_factor) of
your proprietary tech?

Gaming is a [$100 billion
market](https://newzoo.com/insights/articles/global-games-market-reaches-99-6-billion-2016-mobile-generating-37/);
mobile is a third of that. How much is your company losing because the "real
artists" are so quick to ship bugs?

If you find yourself in this position, your
best option may be to find a new employer. When you're interviewing, ask the
interviewer about their software practices. Is there automated testing? Are
there code reviews? Static analysis? Linting? What's the test coverage? What
sort of tests are there? Is there a style guide which prohibits certain
dangerous practices? Are third-party libraries kept up to date to minimize
security holes and duplicated patching efforts?

### A note to "real artists"
If I could whisper in your ear, I'd note that there's no point shipping a
product not worth shipping. I'd note that repeated bastardization of software
practices leads to an unmaintainable mess. I'd ask you to attempt to quantify
the summation of all "real artist" moments you've had, where sane practice was
abandoned. Was it worth it? What was the cost? Is it too late?

<figure><figcaption style="font-style: italic;">
"Real artists don't ship, they provoke. In today's world, shipping is the easy
part. Making something meaningful that questions the status quo is the real
challenge." ~ <a href="https://www.quora.com/What-does-real-artists-ship-mean-to-you/answer/Natalie-Edward-Phillips-Hamblett">Natalie Edward Phillips-Hamblett</a>
</figcaption></figure>
