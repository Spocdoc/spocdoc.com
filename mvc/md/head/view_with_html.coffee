Marked = require 'marked-fork'
getOffset = require './offset'
htmlPos = require './offset_to_html'
mdText = require './md_text'
mdOffset = require './md_offset'
debugError = global.debug 'ace:error'
# rangy = require '
MODE_TEXT = 0
MODE_HTML = 1
KEY_ESC = 27
KEY_ENTER = 13

module.exports =
  outlets: ['md']

  outletMethods: [
    (md) ->
      if @mode is MODE_HTML
        @setHtml md
      return
  ]

  setHtml: (md) ->
    if @mode is MODE_TEXT
      offsets = @getTextSelectionOffsets()
    @mode = MODE_HTML
    @$content.toggleClass 'mdtext', false
    try
      @marked = new Marked md
      @$content.html ''+@marked
      $.selection htmlPos(@$contents, offsets.start), htmlPos(@$contents, offsets.end) if offsets
    catch _error
      debugError _error
      @setText md
    return

  setText: (md) ->
    if @mode is MODE_HTML
      offsets = @getOffsets()
    @mode = MODE_TEXT
    @$content.toggleClass 'mdtext', true
    @$content.text md
    if offsets
      container = @$content.contents()[0]
      $.selection
        start:
          container: container
          offset: offsets.start
        end:
          container: container
          offset: offsets.end
    return

  getTextSelectionOffsets: ->
    if selection = $.selection()
      return {
        start: mdOffset @$content, selection.start
        end: mdOffset @$content, selection.end
      }

  getOffsets: ->
    if selection = $.selection()
      {start,end} = selection
      offset = getOffset start
      return {
        start: offset
        end: if start.container is end.container and start.offset is end.offset then offset else getOffset end
      }

  constructor: ->
    @marked = 0
    @mode = MODE_HTML

    @$content.on 'mousedown', 'a', =>
      @$content.removeAttr 'contenteditable'
      return

    @$content.on 'keydown', (event) =>
      if @mode is MODE_HTML
        @setText @marked.src
      switch event.keyCode
        when KEY_ENTER
          start = $.selection()?.start
          $.selection.delete()
          $.selection $.addText(start, '\n', true).end if start
          event.preventDefault()
          return false
      return

    @$content.on 'mouseup, keyup', =>
      if @mode is MODE_TEXT
        @md.set text = mdText @$content
        switch event.keyCode
          when KEY_ESC
            @setHtml text
      return

    @$content.on 'blur', =>
      if @mode is MODE_TEXT
        text = mdText @$content
        @md.set text
        @setHtml text
      return
        


