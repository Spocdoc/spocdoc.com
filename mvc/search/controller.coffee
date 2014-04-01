_ = require 'lodash-fork'
dates = require 'dates-fork'

module.exports =
  view: 'with_sidebar'

  outlets: [
    'doc'
    'number'
  ]

  internal: [
    'queryText'
    'queryTags'
    'queryDateStart'
    'queryDateEnd'
    'query'
    'allDates'
    'subTags'
  ]

  $main: -> new @View['search/page'] this, 'main',
    field: @controllers['field']
    results: @controllers['results']
    
  $sidebar: -> new @View['sidebar_split'] this, 'sidebar',
    top: @controllers['top']
    bottom: @controllers['bottom']

  addTagToSearch: (tag) ->
    if @controllers['field'].addTag tag
      @number.set 1+(@number.get()|0)
    return

  # for tabs
  getCell: (tab) -> @controllers[tab]
  freeCell: (tab) ->

  refreshQuery: ->
    if query = @query.value
      query.refresh()
      @tagsQuery.refresh()
      @dateQuery.refresh()
    return

  updateQuery: (spec=[]) ->
    queryText = ''
    queryTags = []
    queryDateStart = null
    queryDateEnd = null

    for part in spec
      switch part.type
        when 'text'
          queryText += " #{_.quote part.value}"
        when 'tag'
          queryTags.push part.value.toLowerCase()
        when 'meta'
          if part.key is 'date'
            [queryDateStart, queryDateEnd] = dates.strRangeToDateRange(part.value)

    if priv = @session.get('user')?.get('priv')?.get()
      queryTags = priv.getSearchTags queryTags
    else
      tmp = []
      tmp[i] = [tag] for tag,i in queryTags
      queryTags = tmp

    currentTags = @queryTags.get()

    if sameTags = currentTags and currentTags.length is queryTags.length
      for tag, i in currentTags when queryTags[i] isnt tag
        sameTags = false
        break

    @queryTags.set queryTags unless sameTags
    @queryText.set queryText
    @queryDateStart.set queryDateStart
    @queryDateEnd.set queryDateEnd
    
    return if @initialized
    @initialized = true

    # initialize query
    @query.set query = new @Model['docs'].Query {
        $text: @queryText
        # tags: $all: @queryTags
        tags: $allc: @queryTags
        date: $gte: @queryDateStart, $lte: @queryDateEnd
    }, null, modified: -1

    # text query is ignored -- can't use in distinct call currently
    @tagsQuery = tagsQuery = new @Model['docs'].Query
        # $text: @queryText
        # tags: $all: @queryTags
        tags: $allc: @queryTags
        date: $gte: @queryDateStart, $lte: @queryDateEnd
        0

    @dateQuery = dateQuery =
      new @Model['docs'].Query
        # $text: @queryText
        tags: $allc: @queryTags
        # tags: $all: @queryTags
        0

    @Model['docs'].on 'reread', =>
      query.refresh()
      tagsQuery.refresh()
      dateQuery.refresh()
      return

    @subTags.set tagsQuery.distinct 'tags'
    @allDates.set dateQuery.distinct 'date'
    return

  constructor: ->
    field = @controllers['field'] = new @View['search/field'] this, 'field',
      name: 'Search documents'

    @controllers['results'] = new @Controller['search/results'] this, 'results',
      query: @query
      spec: field.spec
      dateStart: field.dateStart
      dateEnd: field.dateEnd
      specTags: field.specTags

    @controllers['Dates'] = new @View["search/sidebar_tabs/dates"] this, "datesContent",
      nonEmpty: @allDates
      dateStart: field.dateStart
      dateEnd: field.dateEnd

    @controllers['Tags'] = new @Controller["search/sidebar_tabs/tags"] this, "tagsContent",
      subTags: @subTags
      specTags: field.specTags
      
    @controllers['top'] = new @View['search/sidebar_top'] this, 'sidebarTop'

    @controllers['bottom'] = new @View['tab_rows'] this, 'sidebarTabs',
      defaultTabs: [
        'Tags'
        'Dates'
      ]
      orderedTabs: -> @session.get('user')?.get('priv')?.get('searchTabs')
      rowStarts: -> @session.get('user')?.get('priv')?.get('searchTabStarts')

    return

