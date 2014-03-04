debugError = global.debug 'ace:error'
dates = require 'dates-fork'
HtmlSnips = require 'marked-fork/html_snips'

showDocLink = -> ['depute','showDoc',@model.get()?.id]

module.exports =
  inlets: [
    'model'
    'words'
    'specTags'
    'dateStart'
    'dateEnd'
    'text': -> @model.get('text')
  ]

  internal: [
    'title'
    'tags'
    'authors' # TODO
    'date'
    'modified'
    'length'
  ]

  $title: link: showDocLink

  title: -> @model.get('title')
  tags: -> @model.get()?.tags()
  date: -> @model.get('date')
  modified: -> @model.get('modified')
  length: -> @model.get('words')

  outletMethods: [
    (words, text) ->
      switch (mode = if words.length then 'snips' else 'head')
        when 'head'
          if @mode isnt mode
            (@head ||= new @View['md/head'] this, 'head').md.set @text
            j =  0
            while j < @snipsInView
              @snips[j].detach()
              ++j
            @snipsInView = 0
            @head.appendTo(@$content, this)

        when 'snips'
          if @mode isnt mode and @head
            @head.md.unset @text
            @head.detach()
          md = new HtmlSnips(text or '', words)
          snips = md.snips
          j = 0
          snipsInView = snips.length
          while j < snipsInView
            (view = @snips[j] ||= new @View['md/snip'] this, "snip#{j}").snip.set snips[j]
            view.appendTo(@$content, this) if j >= @snipsInView
            ++j
          while j < @snipsInView
            @snips[j].detach()
            ++j
          @snipsInView = snipsInView
      return

    (title) ->
      @$titleH1.toggleClass 'empty', !title
      @$title.text title || ''
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

    @$header.link 'click', this, '', ($target, event) =>
      $target = $(event.target) # don't use currentTarget (the default)
      if tag = $target.attr('data-tag')
        ['depute','addTagToSearch',$target.attr('data-tag')]
      else
        ['depute','showDoc',@model.get()]

    @$header.on 'mouseenter', 'li', =>
      @$article.addClass 'no-bg'

    @$header.on 'mouseleave mousedown', 'li', =>
      @$article.removeClass 'no-bg'

    @snips = []
    @snipsInView = 0
    @head = null

    @mode = ''

    return





