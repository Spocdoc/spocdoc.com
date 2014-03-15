Outline = require 'marked-fork/outline'
strdiff = require 'diff-fork/lib/types/string'
debugError = global.debug 'ace:error'
debug = global.debug 'app:md:outline'

module.exports =
  outlets: [
    'doc'
    'md': -> @doc.get('text')
  ]

  outletMethods: [
    (doc, md='') ->
      return if !md and !doc

      if outline = @outline
        outline.update md
      else
        outline = @outline = new Outline md, (if @template.bootstrapped then @$root else null)
        @$root.prepend outline.$root
      return
  ]

  constructor: ->
    @$root.on 'click', 'p', (event) =>
      return unless (p = event.currentTarget) and outline = @outline
      @depute 'scrollToOffset', outline.posToOffset
        'container': p
        'offset': 0

