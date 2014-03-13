snips = require 'marked-fork/snips'
strdiff = require 'diff-fork/lib/types/string'
debugError = global.debug 'ace:error'
debug = global.debug 'app:head_md'

module.exports =
  outlets: ['md']

  outletMethods: [
    (md='') ->
      # @$content.html (new HtmlHead md, 5).html
      return
  ]

