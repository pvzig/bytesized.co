---
date: 2017-08-20
title: SlackKit 4.0.0
path: slackkitv4
---
Back in June, I released a new major update to [SlackKit](https://www.github.com/SlackKit/SlackKit "SlackKit"), my Swift framework for building Slack apps. There were three big goals for this release — I wanted to make it universal, make it modular, and make it extensible.

## Universal
Prior to the [new release](https://github.com/SlackKit/SlackKit/releases/tag/4.0.0 "SlackKit Version 4.0.0"), there were two separate branches for SlackKit — one that targeted Apple’s platforms (iOS/macOS/tvOS), and one that targeted linux. Not only did this cause confusion for people trying to use the library, but it was also a maintenance headache trying to keep both branches in sync.

The progress made by the Foundation Project on [swift-corelibs-foundation](https://github.com/apple/swift-corelibs-foundation "Swift Foundation") over the past year has made unification plausible. Key classes like `URLSession` were implemented, and overall quality has greatly improved. Swift 3.1.1 is the first version of Swift where the Foundation frameworks have started to feel like a solid foundation on linux as well as on Apple’s platforms.

The trickiest part about going universal was wrangling SlackKit’s third-party dependencies. Most popular open source Swift projects today are focused on iOS or macOS and don’t support linux, so I needed to find alternatives where necessary.

## Modular
In addition to being universal, SlackKit is now also modular so that if you don’t need everything that SlackKit offers, you can just pull in the parts you need. I ended up breaking it up into the following 5 modules:

 - [SKWebAPI](https://www.github.com/SlackKit/SKWebAPI "SKWebAPI") - a wrapper for the Slack Web API
 - [SKRTMAPI](https://www.github.com/SlackKit/SKRTMAPI "SKRTMAPI") - a web socket module for connecting to the Slack Real Time Messaging API
 - [SKServer](https://www.github.com/SlackKit/SKServer "SKServer") - a server module for handling OAuth, slash commands, and more
 - [SKClient](https://www.github.com/SlackKit/SKClient "SKClient") - a client module for tracking and managing client state
 - [SKCore](https://www.github.com/SlackKit/SKCore "SKCore") - a core library for shared model objects

## Extensible
Finally, SlackKit is now designed to be extensible. This means that if you don’t like the defaults, it’s relatively easy to plug into SlackKit by conforming to the real-time messaging, server, or client protocols. The server-side Swift ecosystem is rich, varied, and growing — being extensible will help SlackKit grow and evolve along with that ecosystem.

I’m very pleased to have this release out the door, but there’s still lots left to do. If you’re interested in helping out, take a look at the [project roadmap](https://github.com/orgs/SlackKit/projects/1) — contributions of all size are always welcome!
