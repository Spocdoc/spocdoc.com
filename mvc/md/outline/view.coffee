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

      # this is so update isn't called if the content is completely different.
      # TODO: a better way would be to look at the diff and heuristically
      # determine whether the tree should be regenerated
      docId = '' + (doc?.id)
      differentDoc = @oldDocId isnt docId
      @oldDocId = docId

      if outline = @outline
        outline.update '' if differentDoc

        if diffstr = strdiff outline.src, md
          eqRanges = strdiff.equalRanges diffstr
          outline.update md, eqRanges
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

