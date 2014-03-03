module.exports =
  view: 'with_sidebar'

  outlets: [
    'doc'
  ]

  $main: -> new @View['search/page'] this, 'main',
    field: @controllers['field']
    resutls: @controllers['results']
    
  $sidebar: -> new @View['sidebar_split'] this, 'sidebar',
    top: @controllers['top']
    bottom: @controllers['bottom']

  # for tabs
  getCell: (tab) -> @controllers[tab]
  freeCell: (tab) ->

  constructor: ->
    field = @controllers['field'] = new @View['search/field'] this, 'search'

    results = @controllers['results'] = new @Controller['search/results'] this, 'results',
      query: field.query
      spec: field.spec
      dateStart: field.dateStart
      dateEnd: field.dateEnd
      specTags: field.specTags

    dates = @controllers['Dates'] = new @View["search/sidebar_tabs/dates"] this, "datesContent",
      nonEmpty: field.allDates

    tags = @controllers['Tags'] = new @Controller["search/sidebar_tabs/tags"] this, "tagsContent",
      subTags: field.subTags
      specTags: field.specTags
      
    top = @controllers['top'] = new @View['search/sidebar_top'] this, 'sidebarTop'

    bottom = @controllers['bottom'] = new @View['tab_rows'] this, 'sidebarTabs',
      defaultTabs: [
        'Tags'
        'Dates'
      ]
      orderedTabs: -> @session.get('user')?.get('priv')?.get('searchTabs')
      rowStarts: -> @session.get('user')?.get('priv')?.get('searchTabStarts')

    return

