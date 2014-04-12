Editor = require 'marked-fork/editor'
Html = require 'marked-fork/html'
constants = require '../../constants'
strdiff = require 'diff-fork/lib/types/string'
debugError = global.debug 'ace:error'
debug = global.debug 'app:article_md'
tagUtils = require '../../../lib/tags'
utils = require '../../../lib/utils'
_ = require 'lodash-fork'

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
  mixins: 'mixins/img_printer'

  outlets: [
    'doc'
    'md': -> @doc.get('text')
    'wordCount': -> @doc.get('words')
    'tags': -> @doc.get('tags')
    'title': -> @doc.get('title')
    'css': -> @doc.get('css')
    'code': -> @doc.get('code')
    'custom': -> @doc.get('custom')
    'modified': -> @doc.get('modified')
    'tldr': -> @doc.get('tldr')
    'public': -> @doc.get('public')
    'editable': -> @doc.get()?.editable()
    'initialPosition' # startOffset, endOffset, carat when rendering a document
    'search'
    'spec'

    'styleDoc': (css) ->
      if (local = utils.localUrl css) and cap = /\/docs\/(?:.*\/)?([0-9a-f]{24})/.exec local
        @Model['docs'].read cap[1]
      else
        @styleLink.set css
        null

    'styleText': -> @styleDoc.get('text')
    'styleLink'
  ]

  outletMethods: [
    (doc) -> @switchModes MODE_HTML

    (styleLink) ->
      html = ''
      if styleLink
        try
          html = """<link href="#{_.unsafeHtmlEscape styleLink}" rel="stylesheet" type="text/css"/>"""
        catch _error

      @$styleLink[0].innerHTML = html
      return

    (styleText) ->
      return if @parsingCss
      unless styleText and (styleDoc = @styleDoc.get())
        @$style[0].innerHTML = ''
        return

      id = @$content.attr 'id'

      getCss = (styleText) =>
        @parsingCss = true

        styleDoc.getCss id, (err, css) =>
          unless err?
            @$style[0].innerHTML = css

          if styleText isnt @styleText.value
            getCss @styleText.value
          else
            @parsingCss = false

          return
      getCss styleText
      return

    (doc, md='', initialPosition, inWindow, spec, editable) ->
      return if !md and !doc and !inWindow

      if spec and spec.length
        words = []
        for part in spec when part.type is 'text' # TODO skip tags and meta
          words.push part.value
        words = null unless words.length

      editor = @getEditor words

      docId = '' + (doc?.id)
      differentDoc = @oldDocId isnt docId
      @oldDocId = docId
      if differentDoc and !(@ace.booting and @template.bootstrapped)
        editor.update ''
        @getEditor(null, +!@mode).update '' # clear *both* editors when the document changes

      if words
        editor.update md

        @scrollTop 0

        if @emptySearch
          editor.$root.detach()
          @emptySearch = false

        unless @ace.booting and @template.bootstrapped
          html = if @mode is MODE_TEXT then "<pre class='root search-results editor'>" else "<div class='root search-results html'>"
          for snip in editor.search(words)
            html += """<div class="section-wrapper"><div class="section"><div class="margin-eater"></div>"""
            html += snip
            html += """</div></div>"""
          html += if @mode is MODE_TEXT then "</pre>" else "</div>"
          @$searchContent.html html
      else

        unless @emptySearch
          @scrollTop 0 if inWindow and !initialPosition
          @$searchContent.empty()
          @$content.append editor.$root
          @emptySearch = true

        if initialPosition
          editor.update md

          if inWindow
            editor.$content.focus()

            @router.setAfterPushArg 'setScroll', false # don't set the scroll position
            {startOffset, endOffset, carat} = initialPosition
            if startOffset? and endOffset?
              # select that range in the current editor
              sel = $.selection editor.offsetToPos(startOffset), editor.offsetToPos(endOffset)
              @moveCarat carat, sel if carat

            @initialPosition.set null
        else unless editor.src is md
          if sel = $.selection()
            start = editor.posToOffset sel.start, false, @$root[0]
            end = editor.posToOffset sel.end, false, @$root[0]

          eqRanges = editor.update md

          if sel and isFinite(start) and isFinite(end)
            start = editor.offsetToPos(eqRanges.updateOffset(start))
            end = editor.offsetToPos(eqRanges.updateOffset(end))
            unless $.selection.equal {start,end}, sel
              $.selection editor.offsetToPos(eqRanges.updateOffset(start)), editor.offsetToPos(eqRanges.updateOffset(end))

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

  switchModes: (mode, start, end=start) ->
    if @mode is mode
      return unless start
      oldEditor = newEditor = @getEditor()
    else
      oldEditor = @getEditor()
      @mode = +!@mode
      newEditor = @getEditor()

    if sel = $.selection()
      start ?= oldEditor.posToOffset sel.start, false, @$root[0]
      end ?= oldEditor.posToOffset sel.end, false, @$root[0]
      oldCarat = $.selection.coords(sel)

    newEditor.update @md.value
    unless newEditor is oldEditor
      oldEditor.$root.detach()
      @$content.prepend newEditor.$root
      newEditor.$root.focus()

    if isFinite(start) and isFinite(end)
      sel = $.selection newEditor.offsetToPos(start), newEditor.offsetToPos(end)
      @moveCarat oldCarat, sel

    return

  updateMeta: (text) ->
    (html = @getEditor null, MODE_HTML).update text
    meta = html.meta
    @wordCount.set meta['words']
    @tags.set tagUtils['forIndexing'] Object.keys(meta['tags'])
    @title.set meta['title']
    @custom.set html.custom
    @modified.set new Date()
    @tldr.set meta['tldr']
    @css.set meta['css']
    @code.set meta['code']
    @public.set utils.makePublic meta
    return

  handleInput: ->
    return unless @mode is MODE_TEXT

    editor = @getEditor()
    root = editor.$content[0]
    text = root.textContent ? root.innerText ? ''
    src = editor.src

    return if src is text

    if sel = $.selection()
      start = editor.posToOffset sel.start, true, @$root[0]
      end = editor.posToOffset sel.end, true, @$root[0]

    editor.update text, true
    @md.set text
    @updateMeta text

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

  getEditor: (words, mode=@mode) ->
    switch mode
      when MODE_HTML
        unless editor = @html
          editor = @html = new Html @md.value, (if @ace.booting and @template.bootstrapped and !words then @$content else null),
            depth: 1
            imgPrinter: @imgPrinter

          editor.$content.attr 'tabindex', '-1'
      else
        unless editor = @editor
          editor = @editor = new Editor @md.value
          editor.$content.attr 'tabindex', '-1'
    editor.$content.prop 'contenteditable', !!@editable.value
    editor

  # TODO handle text updates or cursor moves during async file read op...
  # TODO show errors on image read or bad drop type
  insertImage: (file, offset) ->
    fileReader = new $.FileReader()
    fileReader.onload = (event) =>
      id = utils.imgId b64 = _.uint8ToB64 new Uint8Array event.target.result
      extension = (''+file.name).replace(/^.*\./,'')

      @depute 'uploadImage', id, b64, extension

      html = @getEditor null, MODE_HTML
      # TODO hardcoded offset for ![
      offset = 2 + html.addImage("#{id}.#{extension}", offset)
      @md.set html.src

      # this also updates the editor src
      @switchModes MODE_TEXT, offset
      return

    fileReader.readAsArrayBuffer file
    return

  constructor: ->
    @html = @editor = null
    @mode = MODE_HTML

    # these enable links
    @$root.on 'mousedown', 'a', (event) =>
      ($a = $(event.target)).prop 'contenteditable', false
    @$root.on 'click', 'a', (event) =>
      ($a = $(event.target)).removeAttr 'contenteditable'
      if (href = $a.attr 'href') and (local = utils.localUrl(href)) and @router.route local
        return false

    @lastEsc = 0

    # don't use input for handleInput -- it introduces a perceptible rendering
    # lag between pressing the key and its appearance on the screen
    @$content.on 'input', (event) => return false if @mode is MODE_HTML or !@editable.value

    @$content.on 'keydown', (event) =>
      return if event.keyCode in KEY_NON_MUTATING or event.keyCode is KEY_F and (event.ctrlKey or event.metaKey)

      if event.keyCode is KEY_ESC
        unless @lastEsc
          @switchModes()
          @lastEsc = Date.now()
        return false

      @switchModes() unless @mode is MODE_TEXT

      return unless @editable.value

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
          return false
        when KEY_TAB
          start = $.selection()?.start
          $.selection.delete()
          $.selection $.addText(start, '\t', true).end if start
          return false

      return

    @$searchContent.on 'click', =>
      return if @emptySearch
      return unless sel = $.selection()
      editor = @getEditor()
      return unless isFinite(startOffset = editor.posToOffset(sel.start, false, @$root[0])) and isFinite(endOffset = editor.posToOffset(sel.end, false, @$root[0]))
      carat = $.selection.coords(sel)
      @search.set ''
      @initialPosition.set {startOffset, endOffset, carat}
      return

    @$content.on 'mouseup keyup', (event) =>
      if event.keyCode is KEY_ESC
        if Date.now() > @lastEsc + TOGGLE_LAG_MILLIS
          @switchModes()
        @lastEsc = 0
        return false

      return false if @mode is MODE_HTML

      if @editable.value
        @handleInput()

      return


    if $.hasDragDrop() and Uint8Array
      @$content.dnd().on
        'dndenter': (dnd, event) =>
          @$dropZone.addClass 'dragenter'
          event.stopPropagation()
          return

        'dndleave': (dnd, event) =>
          @$dropZone.removeClass 'dragenter'
          return

        # 'dragover': (event) =>
        #   return false unless okDrag

        'drop': (event) =>
          @$dropZone.removeClass 'dragenter'

          return false unless dataTransfer = event.originalEvent.dataTransfer

          # grab all the dropped images
          images = []
          for file in dataTransfer.files when _.imgMime file.name.replace(/^.*\./,'')
            images.push file
          return false unless images[0]

          insertOffset = 0

          # select the drop point
          if range = $.selection event.originalEvent
            start =
              'container': range.startContainer
              'offset': range.startOffset
            insertOffset = @getEditor().posToOffset start, false, @$root[0]

          for image in images.reverse()
            @insertImage image, insertOffset

          # @addFiles fileList if fileList = event.originalEvent?.dataTransfer?.files
          # @$step1Instructions.text "Drag them here."
          # @$fileChooser.css 'display', 'none'
          false

