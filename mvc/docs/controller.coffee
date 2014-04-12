typeToClass = require('lodash-fork').makeCssClass
regexObjectId = /^[0-9a-f]{24}$/
defaultImgPrinter = require 'marked-fork/lib/img_printer'
_ = require 'lodash-fork'

module.exports =
  mixins: 'mixins/img_uploader'

  view: 'with_sidebar'

  outlets: [
    'id'
    'doc': (id) -> @Model['docs'].read id
    'initialPosition'
  ]

  $main: -> @controllers['main']
  $sidebar: -> new @View['sidebar_split'] this, 'sidebar',
    top: @controllers['top']
    bottom: @controllers['bottom']

  # for tabs
  getCell: (tab) ->
    tabClass = typeToClass tab
    @controllers[tabClass] ||= new @View["docs/sidebar_tabs/#{tabClass}"] this, "#{tabClass}_content"
  freeCell: (tab) ->

  constructor: ->
    field = @controllers['field'] = new @View['search/field'] this, 'field',
      name: 'Search within'

    main = @controllers['main'] = new @View['md/article'] this, 'main',
      doc: @doc
      initialPosition: @initialPosition
      search: field.search
      spec: field.spec

    @controllers['top'] = new @View['docs/sidebar_top'] this, 'sidebarTop',
      search: field
      editable: main.editable

    @controllers['outline'] = new @View['md/outline'] this, 'outline_content',
      doc: @doc
      deputy: main

    @controllers['bottom'] = new @View['tab_rows'] this, 'sidebarTabs',
      defaultTabs: [
        'Outline'
        'Media'
      ]
      orderedTabs: -> @session.get('user')?.get('priv')?.get('docTabs')
      rowStarts: -> @session.get('user')?.get('priv')?.get('docTabStarts')

    return

