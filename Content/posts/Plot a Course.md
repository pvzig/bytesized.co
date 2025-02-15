---
date: 2020-06-20
title: Plot a Course
path: plot.html
---
A few years ago as a part of my explorations with Swift, I started [statically generating](/posts/generated-swiftly.html) this site using Swift. Now, this was way back in the bad old days of Swift 3, before we had modern conveniences like ABI stability — so when I upgraded my personal laptop this winter, I inadvertently lost the Swift toolchain that I had used to compile my customized fork of [Spelt](https://github.com/njdehoog/Spelt). After a bit of spelunking, I realized that it had been built with some beta version of Xcode long since lost to the sands of time — I was stuck with a binary I couldn’t run.

As Spelt was no longer being actively developed, rather than take the time to convert it to Swift 5 and recompile I used the disruption as an opportunity to move to a newly released Swift static site generator, [John Sundell's](https://twitter.com/johnsundell) [Publish](https://github.com/JohnSundell/Publish). Over the course of the week I spent converting this site to use Publish, I was frustrated by a lot of the built-in assumptions and general inflexibility. While I am sure that it is a great [Swift by Sundell](https://www.swiftbysundell.com) generator, it is not (yet) a great general-purpose static site generator.

But the beauty of open source is exactly that, so I [forked it](https://github.com/pvzig/Publish) and fixed my two biggest issues. The first issue is that it insists on using [Ink](https://github.com/JohnSundell/Ink) as the Markdown parser. Ink doesn't fully support [CommonMark](https://commonmark.org) and couldn't correctly parse some of my posts so I added a [custom content parser](https://github.com/pvzig/Publish/commit/74ab20ae5559f9e6c10ef0821e2325a7074ead79) block and replaced Ink with this [CommonMark package](https://github.com/SwiftDocOrg/CommonMark). This also provided me an entry point where I could add parsing for [markdown footnotes](https://github.com/pvzig/bytesized.co/blob/master/Sources/bytesized/CommonMark%2BFootnotes.swift)[^1]. The second paper cut was the lack of control over paths. The simple fix was to add a new mode for [clean links](https://github.com/pvzig/Publish/commit/248092234a0152516db894999e581371aa116876) but it would have been nice for a bit more built-in flexibility here.

One of the things about Publish that is technically neat is it's HTML DSL[^2] [Plot](https://github.com/JohnSundell/Plot). What this means in practice is that you can write HTML in Swift like this:

```swift
let body = HTML(
    .body(
        .div(.class("pure-g"),
             .div(.class("pure-u-0-4 pure-u-md-1-12 pure-u-lg-1-4")),
             .div(.class("pure-u-1-1 pure-u-md-5-6 pure-u-lg-1-2"),
                  .header(for: self),
                  .itemList(for: items),
                  .paginator(currentPage: page, context: self)
             ),
             .div(.class("pure-u-0-4 pure-u-md-1-12 pure-u-lg-1-4"))
        ),
        .footer(for: site)
    )
)
```

Like I said, kinda neat! In practice I found it to be more clunky and mistake-prone than just writing HTML with [Mustache](https://mustache.github.io) templates, which is what I was converting from.

My last complaint is a more general one — Swift generics are still too difficult to use, and the error messages provided by Xcode make them unapproachable for novices and experts alike. I would do everything I could to not expose generics in the API of a library I published.

Above gripes aside, my overall experience was a positive one. The "steps" model used by Publish makes the whole system extensible by design, and the included RSS feed generator step 
means that this site now has [one](/feed.rss). I was able to easily add and plug in a [S3 deployment method](https://github.com/pvzig/bytesized.co/blob/master/Sources/bytesized/main.swift#L65) that uses the AWS CLI, which ended up inspiring me to convert the whole process into a [Github Action](https://github.com/pvzig/bytesized.co/blob/master/.github/workflows/deploy.yml) that builds and deploys the site automatically whenever I push to `main`. Oh, and there's a dark mode theme now.

If you're interested, the full source is available [here](https://github.com/pvzig/bytesized.co)[^3].

[^1]: Included in "extended" markdown syntax.
[^2]: Domain-specific language.
[^3]: There are a few interesting expansions of Publish's functionality in there like pagination.