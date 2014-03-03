{unsafeHtmlEscape} = require 'lodash-fork'
regexTag = /(?:^|\s+)tag(?!\S)/
regexEdit = /(?:^|\s+)edit(?!\S)/

module.exports = class Tag
  constructor: (content) ->
    @['$tag'] = $ "<span class='tag tab' contenteditable='false' unselectable='on'>#{unsafeHtmlEscape(content)}</span>"
    @['state'] = 'tab'

  'finish': (text) ->
    @['state'] = 'finished'
    @['$tag'].attr 'class', 'tag'
    text ?= @['$prefix'].text() + @['$text'].text() if @['$prefix']
    @['$tag'].text text if text?
    return

  'tab': (text) ->
    if @['$prefix']
      text ?= @['$prefix'].text() + @['$text'].text()
      delete @['$prefix']
      @['$tag'].attr 'class', 'tag tab'
      @['state'] = 'tab'
    @['$tag'].text text if text?
    return

  'edit': (prefix=@['$tag'].text(), text='') ->
    @['state'] = 'edit'
    @['$tag'].attr 'class', 'tag edit'
    @['$tag'].html "<span class='prefix'>#{unsafeHtmlEscape prefix}</span><span class='text' contenteditable='true' unselectable='off'>#{unsafeHtmlEscape text}</span>"
    children = @['$tag'].children()
    @['$prefix'] = $ children[0]
    @['$text'] = $ children[1]
    return

  'inDom': -> !!@['$tag'][0].parentNode

  @['isTag'] = (node) -> regexTag.test node.className
  @['isSelectable'] = (node) -> regexTag.test(node.className) and !regexEdit.test(node.className)

  @['finishedTagText'] = (content) ->
    "<span class='tag' contenteditable='false' unselectable='on'>#{unsafeHtmlEscape(content)}</span>"

