typeToClass = require 'manifest_mvc/type_to_class'

module.exports =
  view: 'with_sidebar'

  outlets: [
    'id'
    'doc': (id) -> @Model['docs'].read id
    'title': -> @doc.get('title')
    'editable': -> @doc.get()?.editable()
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
    @controllers['main'] = new @View['md/article'] this, 'main',
      doc: @doc
      editable: @editable

    field = @controllers['field'] = new @View['search/field'] this, 'field'
    @controllers['top'] = new @View['docs/sidebar_top'] this, 'sidebarTop',
      search: field
      editable: @editable

    @controllers['outline'] = new @View['md/outline'] this, 'outline_content',
      doc: @doc

    @controllers['bottom'] = new @View['tab_rows'] this, 'sidebarTabs',
      defaultTabs: [
        'Outline'
        'Media'
      ]
      orderedTabs: -> @session.get('user')?.get('priv')?.get('docTabs')
      rowStarts: -> @session.get('user')?.get('priv')?.get('docTabStarts')

    return

