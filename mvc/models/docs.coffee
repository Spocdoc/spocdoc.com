_ = require 'lodash-fork'
dates = require 'dates-fork'
Outlet = require 'outlet'

module.exports =
  # tags: ->
  #   @_tags ||= new Outlet (=>
  #     tags = @get('tags').get() || [] # always lower case

  #     if priv = @session.get('user')?.get('priv')?.get()
  #       priv.getDisplayTags tags
  #     else
  #       tags
  #   ), null, true

  static:
    build: (globals, text, meta=0) ->
      # TODO
      return
      # desc = new Desc text

      # if priv = globals.session.get('user').get('priv')?.get()
      #   priv.addTags desc.tags

      # tags = tagUtils.forIndexing desc.tags

      # if date = meta.date
      #   created = modified = meta.date
      # else
      #   date = created = modified = new Date()

      # date = dates.dateToNumber(date)

      # @create
      #   text: text
      #   tags: tags
      #   tagOffsets: desc.tagOffsets
      #   created: created
      #   modified: created
      #   date: date
      #   title: desc.meta.title || ''
      #   words: desc.wordCount

  linkHtml: (target) ->
    # TODO
    content = @get('text').get().substr(0,20)
    """<a href="#" #{if target then "target='#{target}' " else ''}>#{_.unsafeHtmlEscape content}</a>"""


