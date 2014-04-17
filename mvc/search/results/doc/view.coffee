debugError = global.debug 'ace:error'
dates = require 'dates-fork'
Snips = require 'marked-fork/snips'
Inline = require 'marked-fork/html/inline'

showDocLink = -> ['depute','showDoc',@model.get()?.id]

module.exports =
  mixins: 'mixins/img_printer'

  inlets: [
    'model'
    'words'
    'specTags'
    'dateStart'
    'dateEnd'
    'text': -> @model.get('text')
  ]

  internal: [
    'title': -> @model.get('title')
    'tags': -> @model.get()?.tags()
    'authors' # TODO
    'date': -> @model.get('date')
    'modified': -> @model.get('modified')
    'length': -> @model.get('words')
  ]

  $title: link: showDocLink


  outletMethods: [
    (words, text, title) ->
      html = ''

      @$titleH1.toggleClass 'empty', !title
      title ||= ''
      inline = new Inline title
      titleHtml = inline.highlight words if words
      words = null if titleHtml # TODO temporary workaround: if title matches, show the head, rather than matches within doc
      titleHtml ||= inline.html()
      @$title.html titleHtml

      for snip in (@snips = new Snips text, words, depth: 1, imgPrinter: @imgPrinter).snips
        html += """<div class="section-wrapper"><div class="section"><div class="margin-eater"></div>"""
        html += snip
        html += """</div></div>"""
      @$content.html html
      return

    (tags, specTags) ->
      empty = !tags or !tags.length
      return if @ace.booting and @template.bootstrapped # for speed

      html = ''
      exclude = {}
      if specTags
        exclude[tag.toLowerCase()] = 1 for tag in specTags

      unless empty
        for tag in tags when !exclude[tag.toLowerCase()]
          html += """<li data-tag="#{tag}">"""
          t = ''
          for part in tag.split '/'
            part = "/#{part}" if t
            t += part
            html += """<a data-tag="#{t}" href="#{$.link(this,'depute','addTagToSearch',t)}">#{part}</a>"""
          html += '</li>'

      @$tags.html html
      @$tags.toggleClass 'empty', !html
      return

    (date, modified, dateStart, dateEnd) ->
      if dateStart and dateEnd and dateStart is dateEnd is date
        if !modified or dates.dateToNumber(modified) is date
          @$date.text ''
          @$date.addClass 'empty'
          return

      return unless date

      start = dates.dateToStr date
      end = dates.dateToStr(modified)

      str = if end is start or !end then start else "#{start} - #{end}"
      @$date.attr 'title', "modified #{modified}"
      @$date.toggleClass 'empty', !str
      @$date.text str
      return

    (length) ->
      @$length.text if length then "#{length} word#{if length > 1 then 's' else ''}" else ''
      return
  ]

  constructor: ->
    @$authors.addClass 'empty' # TODO

    @$article.link 'click', this, '', ($target, event) =>
      $target = $(event.target) # don't use currentTarget (the default)
      if tag = $target.attr('data-tag')
        return ['depute','addTagToSearch',$target.attr('data-tag')]
      else if @snips and (sel = $.selection()) and isFinite(start = @snips.posToOffset sel.start) and isFinite(end = @snips.posToOffset sel.end)
        ['depute','showDoc',@model.get()?.id, start, end, $.selection.coords(sel)]
      else
        ['depute','showDoc',@model.get()?.id]

    @$header.on 'mouseenter', 'li', =>
      @$article.addClass 'no-bg'

    @$header.on 'mouseleave mousedown', 'li', =>
      @$article.removeClass 'no-bg'

    @snips = []
    @snipsInView = 0
    @head = null

    @mode = ''

    return





