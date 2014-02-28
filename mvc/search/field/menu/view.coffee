_ = require 'lodash-fork'

module.exports =
  outlets: [
    'tagFilterResults'
    'choiceMethod': 'key' # click or key
    'activeRow'
  ]

  activeRow: (tagFilterResults) ->
    activeText = (oldActive = @activeRow.get())?.text

    i = 0
    html = ''
    for section in tagFilterResults when section?.length
      html += "<hr>" if i
      html += "<ul>"
      lastTags = null

      for row in section
        text = (@rows[i] = row).text
        newIndex = i if activeText is text

        html = html + "<li#{if !i or row.expands then " class='adorned'>" else ">"}"
        html = html + "<div class='tab'>tab</div>" unless i
        html = html + "<div class='slash'>/</div>" if row.expands

        if tagFilterResults.noMatchRange
          if lastTags is row.tags
            from = text.length - 1 - !!row.expands
            offset = 0 unless ~(offset = text.lastIndexOf('/',from))
            html = html + "<span class='stem'>#{_.unsafeHtmlEscape text.substr(0,offset)}</span>#{_.unsafeHtmlEscape text.substr(offset)}"
          else
            html = html + _.unsafeHtmlEscape row.text

        else
          matched = row.matched
          if lastTags is row.tags
            html = html + "<span class='stem'>"
            endStem = row.path.length - 1 - !!row.expands
          else
            endStem = null

          for part,j in row.path
            html = html + "</span>" if j is endStem

            j *= 2
            html = html + '/' if j > 0

            unless matched[j+1]? and part
              html = html + _.unsafeHtmlEscape part

            else
              html = html + _.unsafeHtmlEscape part.substring 0, matched[j]

              if matched[j] or matched[j+1]
                html = html + "<span class='matched'>#{_.unsafeHtmlEscape part.substr matched[j], matched[j+1]}</span>"

              if part.length > next = matched[j] + matched[j+1]
                html = html + _.unsafeHtmlEscape part.substr next

        lastTags = row.tags
        html = html + "</li>"
        ++i

      html = html + "</ul>"

    @rows.length = i
    @$root.html html
    @listItems = @$root.find 'li'

    return undefined unless i and oldActive

    newIndex ||= 0
    oldActive[k] = v for k,v of @rows[newIndex]
    oldActive.index = newIndex
    @activeRow.modified()

  outletMethods: [
    (tagFilterResults, activeRow) ->
      unless !activeRow is !@_oldIndex?
        @$root.toggleClass 'focus', activeRow

      $(li).removeClass 'selected' if li = @listItems[@_oldIndex]
      if li = @listItems[index = activeRow?.index]
        ($li = $(li)).addClass 'selected'

        unless @choiceMethod.get() is 'mouse'
          menuTop = @$root.scrollTop()
          menuBottom = menuTop + @$root.innerHeight()
          liTop = li.offsetTop
          liBottom = liTop + $li.outerHeight()
          
          if liTop < menuTop or liBottom > menuBottom
            @$root.stop()
            @$root.animate scrollTop: liTop, 150
        else
          @$root.stop()

      @_oldIndex = index
      return

    (inWindow) ->
      @moveTo @y, @x if inWindow
      return
  ]

  next: ->
    if len = @rows.length
      @choiceMethod.set 'key'
      index = if (activeRow = @activeRow.value) then (activeRow.index+1) else len
      @_setActiveRow if index >= len then 0 else index
    return

  prev: ->
    if len = @rows.length
      @choiceMethod.set 'key'
      index = if (activeRow = @activeRow.value) then (activeRow.index-1) else -1
      @_setActiveRow if index < 0 then len-1 else index
    return

  moveTo: (@y, @x) ->
    if @inWindow.value
      padding = parseInt(@$root.css('padding-left'), 10)
      border = parseInt(@$root.css('border-left-width'), 10)

      @$root.css 'left', "#{x - padding - border}px"
      @$root.css 'top', "#{y}px"
    return

  reset: ->
    @activeRow.set undefined

  _setActiveRow: (index) ->
    index ||= 0

    row = @activeRow.value || {}
    row.index = index
    row[k] = v for k,v of @rows[index]

    @activeRow.set row, _.makeId()
    return

  constructor: ->
    @rows = []
    @listItems = []

    menu = @$root[0]

    @$root.on 'mouseup', (event) =>
      return unless li = event.target

      # find LI
      while (''+li.nodeName).toLowerCase() isnt 'li'
        return if (li is menu) or !(li = li.parentNode)

      index = $.getChildIndex li

      # find UL
      ul = li.parentNode
      while (''+ul.nodeName).toLowerCase() isnt 'ul'
        return if (ul is menu) or !(ul = ul.parentNode)

      # find section
      sectionNumber = 0
      while ul = ul.previousSibling when (''+ul.nodeName).toLowerCase() is 'ul'
        ++sectionNumber

      # add cumulative result count for previous sections
      return unless results = @tagFilterResults.value
      `for (var i = 0, section; i < sectionNumber; ++i) if (section = results[i]) index += section.length;`

      @choiceMethod.set 'mouse'
      @_setActiveRow index
      return
