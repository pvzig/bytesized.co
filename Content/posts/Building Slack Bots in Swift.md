---
date: 2016-05-05
title: Building Slack Bots in Swift
path: swift-bots
---
As a remote iOS developer, I love [Slack](https://slack.com). It’s both my meeting room and my water cooler. As [interest in bots exploded](https://www.techcrunch.com/2015/12/15/trophy-emoji), my interest was piqued. Of course I was interested in writing bots for one of my favorite services! My love of Slack and my love of Apple’s new programming language, [Swift](https://www.swift.org), came together in the form of [SlackKit](http://www.slackkit.co), a Slack client library for iOS, tvOS, and macOS. Unfortunately, it’s not very practical to have to run your Slack bots on a Mac or iPhone, and SlackKit wasn’t compatible with Linux — [until now](https://github.com/pvzig/SlackKit/tree/linux).

## Zewo to Sixty on Linux
Even in the rapidly changing world of technology, the server-side Swift ecosystem is very new. Apple’s [Linux Foundation port](https://github.com/apple/swift-corelibs-foundation) is a huge undertaking, as is the work to get [libdispatch](https://github.com/apple/swift-corelibs-libdispatch), one of the main concurrency frameworks that Foundation relies upon, up and running on the platform. Fortunately, a vibrant ecosystem of open source software has emerged to fill in the gaps left by Apple’s official libraries. In researching the [possibilities for Swift on Linux](https://bytesized.co/swift-everywhere.html), I discovered the open source organization [Zewo](http://www.zewo.io), a large part of this budding community. If this sounds interesting to you, you should [get involved](https://www.github.com/zewo/zewo)! (Oh, and of course they have a [Slack](http://slack.zewo.io))

## Do You Want to Build a Slack Bot?
The following is a step-by-step guide to writing a Slack bot in Swift and deploying to Heroku. The focus here is on macOS but this is also doable on Linux — just skip the Xcode steps and use your editor of choice.

_[Update 1/2/2017: I’ve updated these instructions to work with Xcode 8.2.1 and the official release of Swift 3.]_

## Building the Application
For our example application, we’re going to be making an application that can render judgement on a very specific question: [Robot or Not](https://www.theincomparable.com/robot)?

First, we need to create the directory for our application and initialize the basic project structure.

```
mkdir robot-or-not-bot && cd robot-or-not-bot
swift package init --type executable
```

Next, let’s edit our `Package.swift` to add the SlackKit package as a dependency:

<script src="https://gist.github.com/pvzig/74e7c4e18b60ac05ff8737bdcd12e34d.js"></script>

and generate our development environment:

```
swift package generate-xcodeproj
```

## Show Me the Swift Code!
To create our bot, we need to open the `robot-or-not-bot.xcodeproj` file we just generated, and edit the `main.swift` file in _Sources > robot-or-not-bot_ to contain our bot logic. The following code uses SlackKit to listen for messages directed at our bot and then respond to them by adding a reaction to the inquiry.
<script src="https://gist.github.com/pvzig/c8f01710d22bfb6f16a9d26819bca81d.js"></script>
## Setting Up Your Slack Bot
Next, we need to create a bot integration in Slack. You’ll need a Slack that you have administrator access to; if you don’t already have one of those to play with, go [sign up](https://slack.com/create). Slack is free for small teams.

1. Go here: https://my.slack.com/services/new/bot
2. Enter a name for your bot. We’re going to go with “robot-or-not-bot” so there’s no confusion about our bot’s sole purpose in life.
3. Click “Add Bot Integration”
4. Copy the API token that Slack generates and replace our placeholder token in `main.swift` with the real deal.
## Testing Locally
With our bot token in place, we’re ready to do some local testing! Back in Xcode, select the robot-or-not-bot command line application target and run your bot (⌘+R).

<img src="/images/run.png" width="95%"/>

Then head over to Slack; robot-or-not-bot’s user presence indicator should be filled in. It’s alive!

<img src="/images/itsalive.jpeg" width="95%"/>

To test if it’s working, ask it if something is a robot:

```
@robot-or-not-bot Darth Vader?
```

robot-or-not-bot should add the 🚫 reaction in response to your question, letting you know that [Darth Vader is **not** a robot](https://www.theincomparable.com/robot/3/index.php).

## Deploying to the ☁️
Now that it’s working locally, it’s time to deploy. To the cloud! We’re going to be deploying on Heroku, so if you don’t have an account go and [sign up for a free one](https://signup.heroku.com).

First, we need to add a [Procfile](https://devcenter.heroku.com/articles/procfile) for Heroku. Back in the terminal, run:

```
echo slackbot: .build/release/robot-or-not-bot > Procfile
```

Next, let’s check in our code:

```
git init
git add .
git commit -am'robot-or-not-bot powering up'
```

Finally, we’ll setup Heroku:

*1.* Install the Heroku [toolbelt](https://toolbelt.heroku.com)
*2.* Log in to Heroku in your terminal:

```
heroku login
```

*3.* Create our application on Heroku and set our buildpack:

```
heroku create --buildpack https://github.com/kylef/heroku-buildpack-swift robot-or-not-bot
```

*4.* Set up our Heroku remote:

```
heroku git:remote -a robot-or-not-bot
```

*5.* Push to master:

```
git push heroku master
```

At this point, you’ll see Heroku go through the build process — exciting!

<img src="/images/pushheroku.png" width="95%"/>

## Run It!
Once the build is complete, run:

```
heroku run:detached slackbot
```

Over in Slack, you’ll see robot-or-not-bot’s user presence indicator fill in. It’s alive! (again)

<img src="/images/allsystemsgo.png" width="95%"/>

Just to be sure if it’s working, we should ask it an existential question:

```
@robot-or-not-bot Robot Or Not Bot?
```

robot-or-not-bot will (sadly, I imagine) add the 🚫 reaction to your question — it knows it is just a computer program, not a robot.
## 🎊 You’re Done! 🎊
Congratulations, you’ve successfully built and deployed a Slack bot written in Swift on to a Linux server!
## Built With:
- [kylef’s Heroku buildpack for Swift](https://github.com/kylef/heroku-buildpack-swift)
- [SlackKit: A Slack client library](https://github.com/pvzig/SlackKit/tree/linux)
- [Zewo: Open source libraries for modern server software](https://github.com/zewo)