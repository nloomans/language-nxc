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
  excludeLowerPriority: false

  # Required: Return a promise, an array of suggestions, or null.
  getSuggestions: (request) ->
    new Promise (resolve) ->
      suggestions = []

      # we aren't case sensetive
      # request.prefix = request.prefix.toLowerCase()

      # grab the item in the docs that match
      for item in docs
        # text = item.displayText.toLowerCase()
        if item.displayText.indexOf(request.prefix) > -1
          add = item
          add.descriptionMoreURL = docsURL+add.descriptionMoreURL;
          add.replacementPrefix = request.prefix
          suggestions.push item

      # sort them so that OnFwd comes before OnFwdReg
      suggestions.sort (a, b) ->
        if a.displayText.length < b.displayText.length
          return -1
        else if a.displayText.length > b.displayText.length
          return 1
        else return 0

      # return the suggestions
      console.log suggestions
      resolve suggestions
      # resolve [{text: 'just a sugestion'}]
