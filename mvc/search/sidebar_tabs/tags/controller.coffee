tagUtils = require '../../../../lib/tags'

module.exports =
  view: 'slides': emptySlide: ''

  inlets: [
    'subTags'
    'specTags'
  ]

  internal: [
    'tagsObject': ->
      if tags = @subTags.get()
        tagUtils.tagsToObject(@globals, tags, @specTags.get())
  ]

  outlets: [
    'scrollTops'
  ]

  outletMethods: [
    (tagsObject) ->
      index = -1
      slides = @$slides.get() || 0
      len = if slides then slides.length else 0
      return unless obj = tagsObject
      while index < len
        unless obj
          if slides
            slides.length = Math.max(index, 0)
            @$slides.modified()
          break
        cell.tags.set obj if cell = @cells[index]
        obj = obj[slides[++index]]
      return
  ]

  push: (name) -> @$slides.push name

  addTagToSearch: (tag) ->
    t = (@$slides.get() || []).join('/')
    t = t + (if t then '/' else '') + tag
    @depute 'addTagToSearch', t

  getCell: (hash, index) ->
    cell = @cells[index] ||= new @View['search/sidebar_tabs/tags/list'] this, "slide_#{index+1}"
    obj = @tagsObject.get() || 0
    slides = @$slides.get() || []

    i = 0
    j = index+1
    obj = obj[slides[i++]] while obj and i < j

    cell.tags.set obj
    cell

  getHeadingHtml: (hash, index) ->
    """<h3>#{hash}</h3>"""

  freeCell: (name) ->


  constructor: ->
    @cells = {}

