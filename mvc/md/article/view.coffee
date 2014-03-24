Editor = require 'marked-fork/editor'
Html = require 'marked-fork/html'
constants = require '../../constants'
strdiff = require 'diff-fork/lib/types/string'
debugError = global.debug 'ace:error'
debug = global.debug 'app:article_md'

TOGGLE_LAG_MILLIS = 300

SCROLL_PADDING = 10

KEY_ESC = 27
KEY_ENTER = 13
KEY_TAB = 9
KEY_LEFT = 37
KEY_RIGHT = 39
KEY_DOWN = 40
KEY_UP = 38
KEY_SHIFT = 16
KEY_META = 91
KEY_CTRL = 17
KEY_ALT = 18
KEY_PGUP = 33
KEY_PGDN = 34
KEY_F = 70

KEY_NON_MUTATING = [
  KEY_LEFT, KEY_RIGHT, KEY_DOWN, KEY_UP
  KEY_SHIFT
  KEY_META
  KEY_CTRL
  KEY_ALT
  KEY_PGUP
  KEY_PGDN
]

MODE_TEXT = 0
MODE_HTML = 1

module.exports =
  outlets: [
    'doc'
    'md': -> @doc.get('text')
    'editable'
    'initialPosition' # startOffset, endOffset, carat when rendering a document
    'search'
    'spec'
  ]

  outletMethods: [
    (doc) -> @switchModes MODE_HTML

    (doc, md='', initialPosition, inWindow, spec, editable) ->
      return if !md and !doc

      if !editable
        @switchModes MODE_HTML

      if spec and spec.length
        words = []
        for part in spec when part.type is 'text' # TODO skip tags and meta
          words.push part.value
        words = null unless words.length

      editor = @getEditor words

      if words
        editor.update md

        @scrollTop 0

        if @emptySearch
          editor.$root.detach()
          @emptySearch = false

        unless @ace.booting and @template.bootstrapped
          html = if @mode is MODE_TEXT then "<pre class='root search-results editor'>" else "<div class='root search-results html'>"
          for snip in editor.search(words)
            html += """<div class="section-wrapper"><div class="section">"""
            html += snip
            html += """</div></div>"""
          html += if @mode is MODE_TEXT then "</pre>" else "</div>"
          @$searchContent.html html
      else

        unless @emptySearch
          @scrollTop 0 if inWindow and !initialPosition
          @$searchContent.empty()
          @$content.prepend editor.$root
          @emptySearch = true

        if initialPosition
          editor.update md

          if inWindow
            @router.setAfterPushArg 'setScroll', false # don't set the scroll position
            {startOffset, endOffset, carat} = initialPosition
            if startOffset? and endOffset? and carat?
              # select that range in the current editor
              sel = $.selection editor.offsetToPos(startOffset), editor.offsetToPos(endOffset)
              @moveCarat carat, sel

            @initialPosition.set null
        else
          if sel = $.selection()
            start = editor.posToOffset sel.start
            end = editor.posToOffset sel.end

          eqRanges = editor.update md

          if sel and isFinite(start) and isFinite(end)
            $.selection editor.offsetToPos(eqRanges.updateOffset(start)), editor.offsetToPos(eqRanges.updateOffset(end))

        if @mode is MODE_HTML
          editor.$content.prop 'contenteditable',!!editable

      return
  ]

  moveCarat: (oldCarat, sel) ->
    return unless oldCarat and newCarat = $.selection.coords(sel)

    $scrollParent = @$scrollParent ||= @$root.scrollParent()
    $scrollParent.scrollTop(Math.round($scrollParent.scrollTop() + newCarat.top - oldCarat.top))

    newCarat = $.selection.coords(sel)

    leftEnd = newLeft = newCarat.left
    oldLeft = oldCarat.left

    if newLeft < oldLeft
      leftStart = newLeft
      width = oldLeft - newLeft
    else
      leftStart = oldLeft
      width = newLeft - oldLeft

    ($caratSpot = @$caratSpot).css('top',(newCarat.top)+'px')
    $caratSpot.addClass('starting').css('left',leftStart+'px').css('width',width + 'px')
    $caratSpot.width() # force draw
    $caratSpot.removeClass('starting').css('left',leftEnd + "px").css('width',0)
    return

  switchModes: (mode) ->
    return true if @mode is mode
    return false if @mode is MODE_HTML and !@editable.value

    oldEditor = @getEditor()
    @mode = +!@mode
    newEditor = @getEditor()

    if sel = $.selection()
      start = oldEditor.posToOffset sel.start
      end = oldEditor.posToOffset sel.end
      oldCarat = $.selection.coords(sel)

    newEditor.update @md.value
    oldEditor.$root.detach()
    @$content.prepend newEditor.$root
    newEditor.$root.focus()

    if sel and isFinite(start) and isFinite(end)
      sel = $.selection newEditor.offsetToPos(start), newEditor.offsetToPos(end)
      @moveCarat oldCarat, sel

    true

  handleInput: ->
    return unless @mode is MODE_TEXT

    editor = @getEditor()
    root = editor.$content[0]
    text = root.textContent ? root.innerText ? ''
    src = editor.src

    return if src is text

    if sel = $.selection()
      start = editor.posToOffset sel.start, true
      end = editor.posToOffset sel.end, true

    editor.update text, true
    @md.set text

    if sel and isFinite(start) and isFinite(end)
      start = editor.offsetToPos(start)
      end = editor.offsetToPos(end)
      $.selection start, end unless $.selection.equal({start,end},$.selection())

    return

  # TODO: this doesn't scroll to offset -- it scrolls to the top of the containing node...
  scrollToOffset: (offset) ->
    return unless article = (if @mode is MODE_TEXT then @editor else @html)
    return unless pos = article.offsetToPos offset

    node = node.parentNode if (node = pos['container']).nodeType is 3
    return unless (top = node.getBoundingClientRect()?.top)?

    # TODO: this is the more *correct* way to do it, but there's a BUG in safari on ios where boundingclientrect for a range returns document relative not viewport relative
    # return unless (top = $.selection.coords(pos).top)?

    $scrollParent = @$scrollParent ||= @$root.scrollParent()
    $scrollParent.animate
      scrollTop: $scrollParent.scrollTop() + top - SCROLL_PADDING
      constants.scrollMillis
    return

  scrollTop: (y) ->
    $scrollParent = @$scrollParent ||= @$root.scrollParent()
    if arguments.length
      $scrollParent.scrollTop y
    else
      $scrollParent.scrollTop()
    return

  getEditor: (words) ->
    switch @mode
      when MODE_HTML
        @html ||= new Html @md.value, (if @ace.booting and @template.bootstrapped and !words then @$content else null), depth: 1
      else
        @editor ||= new Editor @md.value, if @ace.booting and @template.bootstrapped and !words then @$content else null

  constructor: ->
    @html = @editor = null
    @mode = MODE_HTML

    # TODO: one approach to clicking editable links
    # @$content.attr 'contenteditable', true
    # @$content.on 'mousedown', 'a', =>
    #   @$content.removeAttr 'contenteditable'
    #   return

    @lastEsc = 0

    @$content.on 'input', =>
      if @mode is MODE_HTML
        event.preventDefault()
        event.stopPropagation()
        return false
      # don't use input -- it introduces a perceptible rendering lag between pressing the key and its appearance on the screen
      # else
      #   @handleInput()
      return

    @$content.on 'keydown', (event) =>
      return unless @editable.value
      return if event.keyCode in KEY_NON_MUTATING or event.keyCode is KEY_F and (event.ctrlKey or event.metaKey)

      if event.keyCode is KEY_ESC
        unless @lastEsc
          @switchModes()
          @lastEsc = Date.now()
        return false

      if @mode is MODE_HTML
        return false unless @switchModes()

      switch event.keyCode
        when KEY_ENTER
          start = $.selection()?.start
          $.selection.delete()
          if start
            # this fixes a presentation bug with trailing newlines in (all?) browsers
            if @editor.$content.isLastChar start
              end = $.addText(start, '\n\n', true).end
              --end.offset
            else
              end = $.addText(start, '\n', true).end
            $.selection end
          event.preventDefault()
          return false
        when KEY_TAB
          start = $.selection()?.start
          $.selection.delete()
          $.selection $.addText(start, '\t', true).end if start
          event.preventDefault()
          return false

      return

    @$searchContent.on 'click', =>
      return if @emptySearch
      return unless sel = $.selection()
      editor = @getEditor()
      return unless isFinite(startOffset = editor.posToOffset(sel.start)) and isFinite(endOffset = editor.posToOffset(sel.end))
      carat = $.selection.coords(sel)
      @search.set ''
      @initialPosition.set {startOffset, endOffset, carat}
      return

    @$content.on 'mouseup keyup', (event) =>
      return unless @editable.value

      if event.keyCode is KEY_ESC
        if Date.now() > @lastEsc + TOGGLE_LAG_MILLIS
          @switchModes()
        @lastEsc = 0
        return false

      if @mode is MODE_HTML
        event.preventDefault()
        return false

      @handleInput()

      return

