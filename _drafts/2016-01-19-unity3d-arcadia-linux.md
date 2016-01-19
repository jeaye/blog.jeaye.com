---
title: Unity3D and Arcadia on Linux
tags: [unity, unity3d, arcadia, linux, clojure, review]
---

For the past decade, [Unity3D](http://madewith.unity.com/) has lacked official
Linux support. Some tenacious users have [worked around this with
WINE](https://github.com/Unity3D-Wine-Support/Unity3D-on-Wine), with varying
degrees of success. Fortunately for us Linux users, [Unity3D is now officially
available
](http://blogs.unity3d.com/2015/08/26/unity-comes-to-linux-experimental-build-now-available/) and support is provided in the new [Linux forums](http://forum.unity3d.com/threads/unity-on-linux-release-notes-and-known-issues.350256/). To improve the situation even more, [Arcadia](https://github.com/arcadia-unity/Arcadia) is also compatible with this new Linux build. I'll cover here how to get things up and running.

### My setup
I'm currently running Arch Linux and using the proprietary nVidia drivers for my
two GTX 670MX cards. This should work on just about any distro, but you should
be sure to use the latest graphics drivers you can; Unity is undoubtedly heavy.

### Installing Unity3D
To get going, hop on over to the [release
thread](http://forum.unity3d.com/threads/unity-on-linux-release-notes-and-known-issues.350256/)
and navigate to the last post. If you're on a Debian-based distribution, you'll
be happy to just find a deb you can install. For the rest of us, there's an
awkwardly unconventional shell script we can run, which also comes with some
binary data embedded in it (~1GB in size). Fair warning.

You should pull down the latest; the commands below are what I used and there
may be a newer version for you. Note that, if you read the script, root is
required for the use of a [chromium suid
sandbox](https://chromium.googlesource.com/chromium/src/+/master/docs/linux_suid_sandbox.md). Fair warning.

```bash
$ wget http://download.unity3d.com/download_unity/linux/unity-editor-installer-5.3.1f1+20160106.sh
$ chmod +x unity-editor-installer-5.3.1f1+20160106.sh
$ su - -c "$PWD/unity-editor-installer-5.3.1f1+20160106.sh"
<enter root password>
```

The dependencies can also be found in the [release thread](http://forum.unity3d.com/threads/unity-on-linux-release-notes-and-known-issues.350256/) and are left to you to figure out.

#### Issues on startup
There's an existing issue where Unity, once installed, requires some directories
which it's apparently unable to create. To be safe, before running Unity, you
should run:

```bash
$ mkdir -p ~/.local/share/unity3d/Unity
```

Also, don't forget to install `npm`, which crept up on me silently. Unity won't
complain about not having it, the start screen just won't show anything.

#### Running Unity
Assuming all went well, you should be able to start up Unity, sign in, and
create some new projects.

```bash
$ ./unity-editor-5.3.1f1/Editor/Unity
```

From here, continue on with your normal Unity workflow
and report all bugs, crashes, etc to the [Unity
forums](http://forum.unity3d.com/forums/linux-editor-support-feedback-experimental.93/).

#### What is Arcadia?
[Arcadia](https://github.com/arcadia-unity/Arcadia) is a new project which
integrates [Clojure CLR](http://clojure.org/about/clojureclr) (Clojure on .NET)
with Unity. This allows not only for writing Unity components, logic, etc in
Clojure, it also allows for integrating a Clojure REPL into the Unity editor for
programmatic manipulation of the scene. We'll see, briefly, what I mean.

#### Installing Arcadia
To install Arcadia, just clone it into the `Assets` directory of your current
project.

```bash
$ cd ~/projects/my-unity-game/Assets
$ git clone https://github.com/arcadia-unity/Arcadia.git
```

If things don't work out of the box, you can take a look at their provided
[Getting
Started](https://github.com/arcadia-unity/Arcadia/wiki/getting-started) wiki
page.

#### Using the REPL

