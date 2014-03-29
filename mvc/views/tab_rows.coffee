_ = require 'lodash-fork'
utils = require '../../lib/utils'
Outlet = require 'outlet'
typeToClass = _.makeCssClass
MIN_ROW_HEIGHT = 260
MAX_ROWS = 6

module.exports =
  inlets: [
    'defaultTabs'
    'orderedTabs'
    'rowStarts'
  ]

  outlets: [
    'clickOrders'
  ]

  internal: [
    'maxRows': (inWindow) ->
      return unless inWindow
      @computeRows() ? @maxRows.value

    'tabs': (defaultTabs, orderedTabs) ->
      if defaultTabs
        if orderedTabs
          @orderedTabs.set tabs = utils.defaultArr defaultTabs, orderedTabs
        else
          tabs = defaultTabs
      else
        tabs = orderedTabs
      if tabs and !@clickOrders.value
        @clickOrders.set tabs.concat().reverse()
      tabs

    'reordered': ->
      if @nRows
        orderedTabs = []
        rows = @rows

        i = 0
        iE = @nRows
        while i < iE
          orderedTabs.push rows[i].orderedTabs.value...
          ++i

        if orderedTabs.length
          @orderedTabs.set orderedTabs
      return
  ]

  computeRows: ->
    if @ace.onServer
      1
    else
      (@$root[0].parentNode.offsetHeight / MIN_ROW_HEIGHT)|0
    # if (parent = @$root.parent()).length and height = @$root.parent().height()
    #   (height / MIN_ROW_HEIGHT)|0

  outletMethods: [
    (rowStarts, tabs, maxRows, reordered) ->
      return if !@ace.onServer and !@inWindow.value

      rowStarts ||= []

      modifiedRowStarts = false
      nTabs = tabs.length
      oldNRows = @nRows
      @nRows = nRows = Math.min(maxRows || 1, nTabs, MAX_ROWS)
      allTabs = {}
      allTabs[tab] = i for tab, i in tabs

      if nRows isnt oldNRows
        @$root.removeClass "split-#{oldNRows}"
        @$root.addClass "split-#{nRows}"

      (seenStarts = {})[tabs[0]] = -1
      for rowStart, i in rowStarts
        break if i+1 is nRows
        if allTabs[rowStart] and !seenStarts[rowStart]?
          seenStarts[rowStart] = i

      rowLengths = []
      n = 0
      for tab, i in tabs
        if i and seenStarts[tab]?
          rowLengths.push(n)
          n = 1
        else
          ++n
      rowLengths.push n
      utils.splitLengths rowLengths, nRows

      rs = 0
      tot = 0
      index = -1
      for rowLen, i in rowLengths
        orderedTabs = tabs.slice(tot, tot + rowLen)
        if row = @rows[i]
          row.rowStartsIndex = index
          row.orderedTabs.set orderedTabs
          row.$root[0].setAttribute('data-index', ''+index) if @ace.onServer
        else
          row = @rows[i] = @buildView index, orderedTabs

        if i >= oldNRows
          row.appendTo(@$root, this)

        if (tot += rowLen) < nTabs
          unless (index = seenStarts[rowStart = tabs[tot]])?
            ++rs while (t = rowStarts[rs]) and seenStarts[t] is rs
            rowStarts[rs] = rowStart
            modifiedRowStarts = true
            index = rs
            ++rs

      # detach old views
      while i < oldNRows
        @rows[i].orderedTabs.set null
        @rows[i].detach()
        ++i

      if modifiedRowStarts
        if @rowStarts.value isnt rowStarts
          @rowStarts.set rowStarts
        else
          @rowStarts.modified()

      return
  ]

  buildView: (index, orderedTabs, name) ->
    name ||= (if @ace.onServer then "server" else "client") + (++@nameIndex)

    view = new @View['tabs'] this, name,
      clickOrders: @clickOrders
      orderedTabs: orderedTabs
    view.rowStartsIndex = index

    if @ace.onServer
      view.$root.attr('data-index',index).attr('data-name',name)

    view.orderedTabs.addOutflow outflow = new Outlet =>
      if ~(rsi = view.rowStartsIndex) and (rowStarts = @rowStarts.value) and (ot = view.orderedTabs.value) and rowStarts[rsi] isnt start = ot[0]
        rowStarts[rsi] = start
        @rowStarts.modified()
      _.makeId()
    outflow.addOutflow @reordered

    view

  bootRow: (rowNode) ->
    return unless rowNode and rowNode.getAttribute and name = rowNode.getAttribute("data-name")
    index = +rowNode.getAttribute("data-index")
    orderedTabs = []

    if li = rowNode.firstChild?.firstChild
      while li
        orderedTabs.push li.getAttribute("data-tab") if li.getAttribute
        li = li.nextSibling

    (@rows[@nRows++] = @buildView index, orderedTabs, name).appendTo(@$root, this)
    return

  constructor: ->
    @rows = []
    @nRows = 0
    @nameIndex = 0

    unless @ace.onServer
      if @ace.booting and @template.bootstrapped
        rowNode = @$root[0].firstChild
        while rowNode
          @bootRow(rowNode)
          rowNode = rowNode.nextSibling

      $(global).on 'resize', =>
        if @inWindow.value
          @maxRows.set @computeRows()
        return
    return

