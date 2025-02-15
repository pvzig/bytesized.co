---
date: 2018-12-21
title: Swift Development with Visual Studio Code — On Linux!
path: vscode.html
---
After reading Mattt's [excellent NSHipster article](https://nshipster.com/vscode/) on building the fledgling [Swift Language Server Protocol](https://github.com/apple/sourcekit-lsp) project, I scrolled back up and stared at *Step 0: Install Xcode*. It didn't seem strictly necessary, based on what followed. And as I’m sure you’ve deduced by the title and existence of this post, it’s not. Below is a short step-by-step guide to building and running the Swift Language Server Protocol on linux[^1]. The following instructions assume either a basic understanding of a unix-style command line and/or a willingness to copy and paste superuser commands from the internet into your terminal program of choice.

1. Install [VS Code](https://code.visualstudio.com) by following these instructions: https://code.visualstudio.com/docs/setup/linux
2. Make sure that you have all the necessary dependencies installed:<pre><code>$ sudo apt install curl git clang libsqlite3-dev libblocksruntime-dev libncurses5-dev</pre></code>
3. Download the [recommended Swift development toolchain](https://github.com/apple/sourcekit-lsp#recommended-toolchain) from [swift.org](https://www.swift.org) or via the command line:<pre><code>$ curl https://swift.org/builds/development/ubuntu1804/swift-DEVELOPMENT-SNAPSHOT-2018-12-07-a/swift-DEVELOPMENT-SNAPSHOT-2018-12-07-a-ubuntu18.04.tar.gz > ~/swift-DEVELOPMENT-SNAPSHOT-2018-12-07-a-ubuntu18.04.tar.gz</pre></code>
4. Extract the toolchain and move it to `/usr/local/bin`:<pre><code>$ sudo tar xzf swift-DEVELOPMENT-SNAPSHOT-2018-12-07-a-ubunutu18.04.tar.gz -C /usr/local/bin</pre></code>
5. Add Swift to your command line path:<pre><code>$ export PATH=/usr/local/bin/swift-DEVELOPMENT-SNAPSHOT-2018-12-07-a-ubuntu18.04/usr/bin:"${PATH}"</pre></code>
Now, let’s run `$ swift --version` to make sure that we’ve downloaded and installed Swift correctly. You should see this output (or similar, depending on the version of the toolchain you installed):<pre><code>Swift version 5.0-dev (LLVM b10ce3d642, Clang c1979d7668, Swift 94b167db75)
Target: x86_64-unknown-linux-gnu</pre></code>
6. Clone and build Apple’s sourcekit-lsp project:<pre><code>$ git clone https://www.github.com/apple/sourcekit-lsp.git
$ cd sourcekit-lsp
$ swift build -Xcxx -I/usr/local/bin/swift-DEVELOPMENT-SNAPSHOT-2018-12-07-a-ubuntu18.04/usr/lib/swift</pre></code>
7. Move `sourcekit-lsp` and `libSwiftPM.so` to `/usr/local/bin`:<pre><code>$ sudo mv .build/x86_64-unknown-linux/debug/sourcekit-lsp /usr/local/bin
$ sudo mv .build/x86_64-unknown-linux/debug/libSwiftPM.so /usr/local/bin</pre></code>
8. Install Node.js 11.x or newer:<pre><code>$ curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
$ sudo apt-get install -y nodejs</pre></code>
9. Generate the extension for VS Code:<pre><code>$ cd Editors/vscode
$ npm run createDevPackage</pre></code>
9. Install the extension you just created:<pre><code>$ code --install-extension out/sourcekit-lsp-vscode-dev.vsix</pre></code>
10. Point sourcekit-lsp at your installed toolchain in VS Code’s settings (*File > Preferences > Settings > settings.json*):<pre><code>"sourcekit-lsp.toolchainPath": "/usr/local/bin/swift-DEVELOPMENT-SNAPSHOT-2018-12-07-a-ubuntu18.04/usr/bin"</pre></code>
11. Reload your VS Code window (*Control+Shift+P > Reload Window*) or restart VS Code.

At this point, you’re all set up to use the Swift Language Server on linux. A few notes: you will see the most functionality for projects that have a `Package.swift` file that have been pre-built with `swift build`.

Let’s clone and build a sample project so we can see it in action:

```
$ git clone https://www.github.com/JohnSundell/Splash.git
$ cd Splash
$ swift build
```
Finally, open the Splash folder in VSCode and try some of the following to see it in action:

- Hover over a `struct` name
- Command+Click to jump to a definition
- Type some code and invoke autocomplete

<center><img src="/images/lsp.png" width="100%"/></center>

There has been a lot of enthusiasm around the announcement of this project, and for good reason. It serves as yet another reinforcement of Apple’s broad goals for the Swift programming language, which seem to extend further beyond the friendly confines of their own platforms with each passing year.

[^1]: Tested on Ubuntu 16.04 and 18.04. The commands below all specify the 18.04 versions where necessary.
