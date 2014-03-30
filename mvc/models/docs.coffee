_ = require 'lodash-fork'
Outlet = require 'outlet'
utils = require '../../lib/utils'

module.exports =
  tags: ->
    @_tags ||= new Outlet (=>
      tags = @get('tags').get() || [] # always lower case

      if priv = @session.get('user')?.get('priv')?.get()
        priv.getDisplayTags tags
      else
        tags
    ), null, true

  editable: ->
    @_editable ||= new Outlet (=>
      # editors is an array of ObjectId's
      return false unless (editors = @get('editors').get()) and id = @session.get('user')?.get()?.id
      id = ''+id
      for editor in editors when id is ''+editor
        return true
      false
    ), null, true

  static:
    build: (ctx, src, meta=0) ->
      doc = utils.makeDoc(src, ctx.user.get(), meta)
      if priv = ctx.userPriv.get()
        priv.addTags doc['tags']
      @create doc

  linkHtml: (target) ->
    # TODO
    content = @get('text').get().substr(0,20)
    """<a href="#" #{if target then "target='#{target}' " else ''}>#{_.unsafeHtmlEscape content}</a>"""


