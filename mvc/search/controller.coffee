_ = require 'lodash-fork'
dates = require 'dates-fork'

module.exports =
  view: 'with_sidebar'

  outlets: [
    'number'
    'frozen'
    'editors'
    'tags'
  ]

  internal: [
    'queryText'
    'queryTags'
    'queryDateStart'
    'queryDateEnd'
    'query'
    'allDates'
    'subTags'
    'spec'

    # tags specified either in tags inlet or in field
    'filteredTags'
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

  outletMethods: [
    (tags) -> @updateQuery @spec.value
  ]

  updateQuery: (spec=[]) ->
    queryText = ''
    queryTags = (@tags.get() or []).concat()
    queryDateStart = null
    queryDateEnd = null
    @spec.set spec # delayed so the snips search isn't char by char

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
        editors: $all: @editors
    }, 10, modified: -1

    @tagsQuery = tagsQuery = new @Model['docs'].Query
        $text: @queryText
        # tags: $all: @queryTags
        tags: $allc: @queryTags
        date: $gte: @queryDateStart, $lte: @queryDateEnd
        editors: $all: @editors
        0

    @dateQuery = dateQuery =
      new @Model['docs'].Query
        $text: @queryText
        tags: $allc: @queryTags
        editors: $all: @editors
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
      name: 'Type to search'

    @filteredTags.set =>
      (field.specTags.get() or []).concat(@tags.get() or [])

    @controllers['results'] = new @Controller['search/results'] this, 'results',
      query: @query
      spec: @spec
      dateStart: field.dateStart
      dateEnd: field.dateEnd
      specTags: @filteredTags #field.specTags
      frozen: @frozen

    @controllers['Dates'] = new @View["search/sidebar_tabs/dates"] this, "datesContent",
      nonEmpty: @allDates
      dateStart: field.dateStart
      dateEnd: field.dateEnd

    @controllers['Tags'] = new @Controller["search/sidebar_tabs/tags"] this, "tagsContent",
      subTags: @subTags
      specTags: @filteredTags #field.specTags
      
    @controllers['top'] = new @View['search/sidebar_top'] this, 'sidebarTop'

    @controllers['bottom'] = new @View['tab_rows'] this, 'sidebarTabs',
      defaultTabs: [
        'Dates'
        'Tags'
      ]
      orderedTabs: -> @session.get('user')?.get('priv')?.get('searchTabs')
      rowStarts: -> @session.get('user')?.get('priv')?.get('searchTabStarts')

    return

