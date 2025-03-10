---
date: 2016-12-19
title: Generated Swiftly
path: generated-swiftly.html
---
After [just about a year](/posts/powered-by-typed-dot-com.html) of being hosted on [Typed](https://www.typed.com), [bytesized.co](https://www.bytesized.co) is now statically generated and hosted on [S3](https://aws.amazon.com/s3/)[^1] — and it’s generated with Swift!

For the static generator, I’m using a [fork](https://github.com/pvzig/Spelt) of the [open source engine](https://github.com/njdehoog/Spelt) that powers the [Spelt](https://spelt.io) blogging software by [Niels de Hoog](https://twitter.com/nielsify). It’s lightning fast and offers some nice features like local preview with auto-regeneration. It’s also easily customizable if you’re familiar with Swift. Under the hood, Spelt uses Kyle Fuller’s Swift template language [Stencil](https://github.com/kylef/Stencil) to provide [Mustache](https://mustache.github.io)-style templating. If you’re curious about what this looks like in practice, I’ve published the source for the new version of the site on [GitHub](https://github.com/pvzig/bytesized.co).

The combination of the Spelt CLI and the [AWS CLI](https://aws.amazon.com/cli/) make updating the site painless. No more copy and pasting articles into a rich-text web editor, hoping the formatting doesn’t get mangled. No more worrying if the site can parse the flavor of markdown I’m writing in. When an article is ready to be published, I just save the **.md** file to the **_posts** directory and run this script:

```bash
cd ~/Sites/bytesized.co/
spelt build
cd _build
aws s3 sync . s3://bytesized.co/ --exclude "*.DS_Store*"
```

Spelt builds the site and any changes are synced with the S3 bucket they’re served from.

Now that I’ve spent a few days refreshing the technical side of the site, I’m looking forward to trying to write more regularly. Moving into the new year my goal is to write at least one post a month — so if you notice that I’m slacking, [remind me](https://www.twitter.com/pvzig).

[^1]: If you’re interested in hosting your own static site on S3, I’d recommend starting with [the guide](http://docs.aws.amazon.com/gettingstarted/latest/swh/website-hosting-intro.html).