docs = require('../docs')
docsURL = 'http://bricxcc.sourceforge.net/nbc/nxcdoc/nxcapi/'

module.exports =
  # This will work on JavaScript and CoffeeScript files, but not in js comments.
  selector: '.source.nxc'
  disableForSelector: '.source.nxc .comment'
  # `excludeLowerPriority` will suppress any providers with a lower priority

  # This will take priority over the default provider, which has a priority of 0.
  # i.e. The default provider will be suppressed
  inclusionPriority: 1
  excludeLowerPriority: !atom.config.get 'language-nxc.allowOtherAutocompleationProvidors'

  watchingDocuments: {}

  localDocs: {}

  updateLocalDocs: ->
    editor = atom.workspace.getActivePaneItem()
    path = editor.buffer.file.path
    @localDocs[path] = []
    for line in editor.buffer.lines
      # is this a function?
      func = /((?:(?:signed|unsigned)[ ]+)*(?:byte|string|bool|char|double|float|int|long|short|void))[ ]+([A-Za-z]+)[ ]*\(([^)]*)\)/.exec line
      if func?
        args = func[3].split(",")
        for arg, i in args
          arg = arg.trim()
          args[i] = "${"+(i+1)+":"+arg+"}"
        add =
          leftLabel: func[1]
          displayText: func[2]
          type:'function'
        add.snippet=add.displayText+"("+args.join(", ")+")"

        @localDocs[path].push add

      else if line.indexOf("#define") == 0
        @localDocs[path].push
          text: line.split(" ")[1]
          type: 'constant'

    varRegEx = /(?:byte|string|bool|char|double|float|int|long|short)[ ]+([\w]+)/g
    editorText = atom.workspace.getActivePaneItem().buffer.getText()
    while true
      currentVar = varRegEx.exec(editorText)
      break unless currentVar?


      addThisOne = true
      for func in @localDocs[path]
        if func.displayText? && currentVar[1] == func.displayText
          addThisOne = false

      @localDocs[path].push
        text: currentVar[1]
        type: 'variable'


    # console.log vars
    # console.log @localDocs


  # Required: Return a promise, an array of suggestions, or null.
  getSuggestions: (request) ->
    return unless request.prefix.length > 0

    editor = atom.workspace.getActivePaneItem()
    editorView = atom.views.getView editor
    path = editor.buffer.file.path
    if !@watchingDocuments[path]?
      @watchingDocuments[path] = "used" # becuse addEventListener doesn't return
      # an event
      @updateLocalDocs()
      editorView.addEventListener 'keydown', (event) =>
        if event.keyIdentifier == "Enter"
          @updateLocalDocs()

    suggestions = []

    # we aren't case sensetive
    # request.prefix = request.prefix.toLowerCase()

    # grab the item in the docs that match
    for item in docs
      # text = item.displayText.toLowerCase()
      if item.displayText.indexOf(request.prefix) > -1
        add = item
        if add.descriptionMoreURL.indexOf(docsURL) == -1
          add.descriptionMoreURL = docsURL+add.descriptionMoreURL;
        add.replacementPrefix = request.prefix
        suggestions.push add

    for item in @localDocs[editor.buffer.file.path]
      if item.displayText?
        currentText = item.displayText
      else
        currentText = item.text

      if currentText.indexOf(request.prefix) > -1
        add = item
        add.replacementPrefix = request.prefix
        suggestions.push add

    # sort them so that OnFwd comes before OnFwdReg
    suggestions.sort (a, b) ->
      if a.displayText?
        aText = a.displayText
      else
        aText = a.text

      if b.displayText?
        bText = b.displayText
      else
        bText = b.text

      if aText.length < bText.length
        return -1
      else if aText.length > bText.length
        return 1
      else return 0

    if !atom.config.get 'language-nxc.showReturnTypeInAutocompleation'
      for suggestion in suggestions
        suggestion.leftLabel = null
    # return the suggestions
    return suggestions
    # resolve [{text: 'just a sugestion'}]
