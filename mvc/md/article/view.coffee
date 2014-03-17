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

updateSrc = (editor, md) ->
  return if editor.src is md

  if sel = $.selection()
    start = editor.posToOffset sel.start
    end = editor.posToOffset sel.end

  eqRanges = editor.update md

  if sel and isFinite(start) and isFinite(end)
    $.selection editor.offsetToPos(eqRanges.updateOffset(start)), editor.offsetToPos(eqRanges.updateOffset(end))

  return


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
    (doc) ->
      @switchToHtml()
      return

    (editable) ->
      unless editable
        @switchToHtml()
      @html?.$content.prop('contenteditable',!!editable)
      return

    (doc, md='', initialPosition, inWindow, spec) ->
      return if !md and !doc

      if spec and spec.length
        words = []
        for part in spec when part.type is 'text' # TODO skip tags and meta
          words.push part.value
        words = null unless words.length

      if @mode is MODE_TEXT
        if editor = @editor
          updateSrc editor, md
        else
          editor = @editor = new Editor md, if @ace.booting and @template.bootstrapped and !words then @$content else null
      else
        if editor = @html
          updateSrc editor, md
        else
          editor = @html = new Html md, (if @ace.booting and @template.bootstrapped and !words then @$content else null), depth: 1

      if words
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
          @scrollTop 0
          @$searchContent.empty()
          @$content.prepend editor.$root
          @emptySearch = true

        if initialPosition and inWindow
          @router.setAfterPushArg 'setScroll', false # don't set the scroll position
          {startOffset, endOffset, carat} = initialPosition
          if startOffset? and endOffset? and carat?
            # select that range in the current editor
            sel = $.selection editor.offsetToPos(startOffset), editor.offsetToPos(endOffset)
            @moveCarat carat, sel

          @initialPosition.set null
      return
  ]

  moveCarat: (oldCarat, sel) ->
    return unless oldCarat and newCarat = $.selection.coords(sel)

    $scrollParent = @$scrollParent ||= @$root.scrollParent()
    $scrollParent.scrollTop(Math.round($scrollParent.scrollTop() + newCarat.top - oldCarat.top))

    newCarat = $.selection.coords(sel)

    # offset = @$root.offset()

    # TOP_DISPLACE = -8
    # LEFT_DISPLACE = -4

    TOP_DISPLACE = 0
    LEFT_DISPLACE = 0

    leftEnd = newLeft = newCarat.left + LEFT_DISPLACE
    oldLeft = oldCarat.left + LEFT_DISPLACE

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

  switchToText: ->
    return true if @mode is MODE_TEXT

    return false unless @editable.value
    @mode = MODE_TEXT

    if (html = @html) and sel = $.selection()
      start = html.posToOffset sel.start
      end = html.posToOffset sel.end
      oldCarat = $.selection.coords(sel)

    md = @md.value || ''

    if editor = @editor
      editor.update md
    else
      editor = @editor = new Editor md

    html?.$root.detach()
    @$content.prepend editor.$root
    editor.$root.focus()

    if sel and isFinite(start) and isFinite(end)
      sel = $.selection editor.offsetToPos(start), editor.offsetToPos(end)
      @moveCarat oldCarat, sel
    true

  switchToHtml: ->
    return true if @mode is MODE_HTML
    @mode = MODE_HTML

    if (editor = @editor) and sel = $.selection()
      start = editor.posToOffset sel.start
      end = editor.posToOffset sel.end
      oldCarat = $.selection.coords(sel)

    md = @md.value || ''

    if html = @html
      html.update md
    else
      html = @html = new Html md, null, depth: 1

    editor?.$root.detach()
    @$content.prepend html.$root
    html.$root.focus()

    if sel and isFinite(start) and isFinite(end)
      sel = $.selection html.offsetToPos(start), html.offsetToPos(end)
      @moveCarat oldCarat, sel
    true

  switchModes: ->
    if @mode is MODE_HTML
      @switchToText()
    else
      @switchToHtml()

  handleInput: ->
    if editor = @editor
      node = editor.$content[0]
      text = node.textContent ? node.innerText ? ''
      src = editor.src

      return if src is text

      if sel = $.selection()
        start = editor.posToOffset sel.start, true
        end = editor.posToOffset sel.end, true

      editor.update text, true

      @md.set text

      if sel and isFinite(start) and isFinite(end)
        # TODO: figure out if it's necessary to change the selection -- the
        # cursor may already be in the right place. moving the cursor causes
        # the spell checker to run
        $.selection editor.offsetToPos(start), editor.offsetToPos(end)

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
        return false unless @switchToText()

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
      return unless editor = (if @mode is MODE_HTML then @html else @editor)
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

      @handleInput()

      if @mode is MODE_HTML
        event.preventDefault()
        return false
      else
        if event.keyCode is KEY_ESC
          @switchToHtml()
          event.preventDefault()
          return false

      return

    # unless @ace.onServer
    #   $('body').on 'focus', '*', (event) =>
    #     if target = event.target
    #       unless @$root.contains target
    #         @switchToHtml()
    #     return


    # @$content.on 'blur', '.editor', =>
    #   if @mode is MODE_TEXT
    #     text = @editor.src
    #     @md.set text
    #     @switchToHtml()
    #   return
