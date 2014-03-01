Outlet = require 'outlet'
_ = require 'lodash-fork'
makeSpec = require './make_spec'
updateDom = require './update_dom'
debug = global.debug 'ace:app:tag_search'
debugSelection = global.debug 'ace:dom:selection'
dates = require 'dates-fork'
badRange = [null,null]

TEXT_NODE = 3

KEY_TAB = 9
KEY_DOWN = 40
KEY_UP = 38
KEY_RIGHT = 39
KEY_LEFT = 37
KEY_BACKSPACE = 8
KEY_SLASH = 191
KEY_SHIFT = 16
KEY_SPACE = 32
KEY_ENTER = 13
KEY_B = 66
KEY_I = 73
KEY_U = 85

updateSelOffset = (offset, lenToPart, origSrc, newSrc) ->
  return newSrc.length if offset is 0
  return offset if offset <= lenToPart or origSrc is newSrc
  delta = (newLen = newSrc.length) - (origLen = origSrc.length)
  return offset + delta if offset > lenToPart + origLen
  return lenToPart + newLen

module.exports =
  outlets: [
    'search'
    'spec': []
    'dateStart'
    'dateEnd'
    'query'
    'subTags'
    'specTags'
    'allDates'
  ]

  internal: [
    # 'menuRow': -> @menuView.activeRow
    # 'menuResults': -> @menuView.tagFilterResults
    # 'menuChoiceMethod': -> @menuView.choiceMethod
    'tagFilterSearch'

    'queryText'
    'queryTags'
    'queryDateStart'
    'queryDateEnd'
    'tagMapDep': ->
      @session.get('user')?.get('priv')?.get()?.tagMapDep

    'specBuilder'

    'queryUpdater': (tagMapDep, specBuilder) -> @updateQuery()
  ]

  $menu: 'view'

  specBuilder: (search) ->
    return search if search is @lastText
    @lastText = search
    @$search.toggleClass 'empty', !search
    @$clear.toggleClass 'hidden', !search

    current = makeSpec search

    @$search.keepSelection =>
      updateDom current, @$search[0]

    @spec.set current

    specTags = @specTags.value || []
    sameTags = true
    tagI = 0
    dateRange = badRange
    for part in current
      if part.key is 'date'
        dateRange = dates.strRangeToDateRange part.value
      else if part.type is 'tag'
        unless (sameTags &&= (specTags[tagI] is part.value))
          specTags[tagI] = part.value
        ++tagI

    unless specTags.length is tagI
      sameTags = false
      specTags.length = tagI

    @dateStart.set dateRange[0]
    @dateEnd.set dateRange[1]
    unless @specTags.value
      @specTags.set specTags
    else unless sameTags
      @specTags.modified()
    return search

  changeSpec: (index, origSrc, newSrc) ->
    lenToPart = 0
    search = ''

    current = @spec.value
    newSrc ?= current[index].src
    origSrc ||= ''

    for part,i in current
      if newSrc and i is index-1 and part.type isnt 'space'
        current.splice(index,0,makeSpec.space)
        newSrc = ' ' + newSrc
        break
      else if i is index
        break
      lenToPart += part.src.length

    search += part.src for part in current

    if sel = $.selection()
      if @$search.contains sel.start.container
        start = updateSelOffset (@$search.textOffset sel.start), lenToPart, origSrc, newSrc
        end = updateSelOffset (@$search.textOffset sel.end), lenToPart, origSrc, newSrc
      else
        sel = null

    empty = !(@lastText = search)
    @$search.toggleClass 'empty', empty
    @$clear.toggleClass 'hidden', empty
    @search.set search
    updateDom current, @$search[0]
    $.selection @$search.textOffsetToPos(start), @$search.textOffsetToPos(end) if sel
    @spec.modified()
    return


  addTag: (tag) ->
    unless current = (spec = @spec).value
      spec.set current = []

    lowerTag = tag.toLowerCase()

    for part in current when part.type is 'tag' and part.value.toLowerCase() is lowerTag
      return false

    @changeSpec current.push(makeSpec.tag tag)-1
    @specTags.push tag
    true

  outletMethods: [
    (dateStart, dateEnd) ->
      if dateStart is false or dateEnd is false
        # want to remove the date
        remove = true
      else
        return unless dateStart and dateEnd

      unless current = (spec = @spec).value
        spec.set current = []

      origSrc = ''
      newSrc = index = null

      for part,i in current when part.key is 'date'
        return if +dateStart is +part.start and +dateEnd is +part.end
        origSrc = part.src
        makeSpec.update part, start: dateStart, end: dateEnd
        index = i
        if remove
          current.splice(i,1)
          newSrc = ''
        break

      unless index?
        return if remove
        index = current.push(makeSpec.meta 'date', start: dateStart, end: dateEnd)-1

      @changeSpec index, origSrc, newSrc
      return
  ]

  updateQuery: ->
    current = @spec.value || []
    queryText = ''
    queryTags = []
    queryDateStart = null
    queryDateEnd = null

    for part in current
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

    @subTags.set tagsQuery.distinct 'tags'
    @allDates.set dateQuery.distinct 'date'

    return

  $clear: link: ['clearSearch']

  clearSearch: -> @search.set ''

  refresh: ->
    if query = @query.value
      query.refresh()
      @tagsQuery.refresh()
      @dateQuery.refresh()
    return

  constructor: ->
    @updateQuery = _.throttle @updateQuery, 250 unless @ace.onServer
    @refresh = _.throttle @refresh, 250 unless @ace.onServer

    @$search.on 'focus', =>
      @refresh()

    @$search.on 'input keydown', (event) =>
      empty = !@$search.text()
      @$search.toggleClass 'empty', text
      @$clear.toggleClass 'hidden', empty
      return

    @$search.on 'keydown', (event) =>
      if event.keyCode is KEY_ENTER
        event.preventDefault()
        event.stopPropagation()
        return false

    @$search.on 'input keyup', (event) =>
      @search.set @$search.text()

      if event.keyCode is KEY_ENTER
        event.preventDefault()
        event.stopPropagation()
        return false
      return
