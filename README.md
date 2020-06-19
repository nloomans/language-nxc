# NXC language support in Atom

language-nxc makes it easier to develop in NXC, which requires little to no setup (depending on your OS / distribution). Its goal is to make developing for NXC easier for everyone.

## Features
### Comping and uploading
built-in (cross-platform) compiling and uploading, try `nxc:upload`. **This works on Linux as well!**

![menu](http://i.imgur.com/92Gd8cA.png)
![bug](http://i.imgur.com/6yuUSmT.png)

The shortcut for `nxc:upload` is Ctrl+Alt+U

### Auto completion
auto completion for ~~built in~~ **all** functions
- description
- link to docs

![Example Usage](http://i.imgur.com/I1v9dMs.gif)

### Syntax highlighting

![syntax highlighting](http://i.imgur.com/SrMTC46.png)

### Enhanced firmware usage

For using the enhanced NXT firmware you have to open the `atom.config.cson` file and add at the end of this one these lines:

"language-nxc":
      useEnhancedFirmware: true

To open the `atom.config.cson` file, go to File/Settings and click on `Open Config Folder`.
