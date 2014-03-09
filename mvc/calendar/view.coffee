Calendar = require './calendar'
dates = require 'dates-fork'

MIN_CELLS_ABOVE = 16
MIN_YEAR = 1990
KEY_DOWN = 40
KEY_UP = 38

module.exports =
  mixins: 'mixins/editable line': 'year'

  outlets: [
    'dateStart'
    'dateEnd'
    'nonEmpty'
    'lastNonEmpty': (nonEmpty) ->
      last = 0
      if nonEmpty
        last = date for date in nonEmpty when date > last
      last

    'scrollDateTop': (lastNonEmpty, dateStart, dateEnd) ->
      return if @onMonth
      if (dateEnd ||= dateStart) and (dateStart ||= dateEnd)
        if @activeKnob is @dateEnd
          dateEnd
        else
          dateStart
      else if lastNonEmpty and !@activeKnob
        lastNonEmpty - (lastNonEmpty%100) # start of month

    'scrollDateBottom': (lastNonEmpty, dateStart, dateEnd) ->
      return if @onMonth or dateStart or dateEnd
      if lastNonEmpty and !@activeKnob
        lastNonEmpty

    'scrollBot'
  ]

  outletMethods: [
    (inWindow, scrollDateTop, scrollDateBottom, scrollBot) ->
      if !inWindow or @ace.onServer
        @_scrollBot = null
        return

      $scrolling = @$scrolling

      if @_scrollBot isnt scrollBot
        scrollHeight = $scrolling.height()
        minHeight = 100 + scrollHeight + scrollBot
        while (fullHeight = $scrolling[0].scrollHeight) < minHeight
          @addBlock block = @calendar.makeBlock()

        @_scrollBot = scrollBot
        $scrolling.scrollTop fullHeight - scrollBot

      return unless (scrollDateTop ||= scrollDateBottom)

      scrollHeight ?= $scrolling.height()

      @ensureDateCreated scrollDateTop

      return unless ($cellTop = @calendar.dateTo$Cell(scrollDateTop)).length
      cellTopPos = $cellTop.position().top

      if scrollDateBottom
        return unless ($cellBottom = @calendar.dateTo$Cell(scrollDateBottom)).length
        cellBottomPos = $cellBottom.position().top

      else
        cellBottomPos = cellTopPos

      cellHeight = $cellTop.height()
      min = cellHeight/2
      max = 3*cellHeight/2

      if cellTopPos < min
        $scrolling.scrollTop($scrolling.scrollTop() + cellTopPos - min)
      else if cellBottomPos > scrollHeight - max
        $scrolling.scrollTop($scrolling.scrollTop() + cellBottomPos - scrollHeight + max)

      return

    (dateStart, dateEnd) ->
      if (dateEnd ||= dateStart) and (dateStart ||= dateEnd)
        @ensureDateCreated dateStart
      @calendar.highlightDates(dateStart, dateEnd)
      return

    (year) ->
      if year < 1990 or year > (new Date()).getFullYear()
        @$year.addClass 'invalid'
      else
        @$year.removeClass 'invalid'
        return if year is @scrollYear
        @ensureDateCreated year*10000+1
        if @inWindow.get() and ($block = @calendar.dateTo$Cell(year*100))
          @$scrolling.scrollTop(@$scrolling.scrollTop() + $block.position().top + 1)
      return

  ]

  ensureDateCreated: (date) ->
    # go 1 month back
    if date%10000/100|0 is 0
      date -= 10000 - 1100
    else
      date -= 100
    while @calendar.dateStart > date
      @addBlock @calendar.makeBlock()
    return

  addBlock: (block) ->
    return if @ace.booting and @template.bootstrapped and $("##{block.id}").length
    @$calendar.prepend block.html
    return

  handleScroll: ->
    cellHeight = (@_cellHeight ||= Math.floor(@calendar.$today().height())) || 26

    @scrollDateTop.set undefined
    @scrollDateBottom.set undefined

    unless scrollTop = @$scrolling.scrollTop()
      minAbove = MIN_CELLS_ABOVE + Math.max(0,((@$scrolling.height() - @$calendar.height())/cellHeight)||0)

      above = 0
      i = 0
      while above < minAbove
        @addBlock block = @calendar.makeBlock()
        above += block.weeks
      @$scrolling.scrollTop above*cellHeight
      scrollTop = @$scrolling.scrollTop()

    @scrollBot.set @_scrollBot = @$scrolling[0].scrollHeight - scrollTop

    @year.set @scrollYear = @calendar.yearFromTop(Math.floor(scrollTop/cellHeight))
    return

  constructor: ->
    @calendar = new Calendar @template.acePrefix, @$calendar, @nonEmpty
    @addBlock @calendar.bottomBlock

    @activeKnob = null
    @clickedKnob = false
    @onMonth = false

    @$year.on 'keydown', (event) =>
      switch event.keyCode
        when KEY_DOWN
          if (year = +@year.get()) and year < (new Date()).getFullYear()
            @year.set year+1
          return false
        when KEY_UP
          if year = +@year.get()
            @year.set year-1
          return false


    unless @ace.onServer
      @$scrolling.on 'scroll', => @handleScroll()

      @$calendar.on 'mouseup mouseleave', =>
        @onMonth = false
        if @clickedKnob
          @clickedKnob = false
          if @dateEnd.value is @dateStart.value
            @dateEnd.set false
            @dateStart.set false
          else if @activeKnob is @dateStart
            @dateEnd.set @activeKnob.value
          else
            @dateStart.set @activeKnob.value
        @activeKnob = null
        @$calendar.addClass 'not-selecting'
        @$calendar.removeClass 'selecting-end'
        @$calendar.removeClass 'selecting-start'
        false

      @$calendar.on 'mousedown', 'td', (event) =>
        return unless (tgt = event.currentTarget) and date = @calendar.cellToDate tgt

        if event.shiftKey and @dateStart.value and @dateEnd.value
          unless date%100
            @onMonth = true
          else
            if date < +@dateEnd.value
              @activeKnob = @dateStart
            else
              @activeKnob = @dateEnd
          shiftAdd event
        else
          unless date%100
            @dateStart.set date+1
            @dateEnd.set date+dates.daysInMonth(date)
            @onMonth = true
          else
            @$calendar.removeClass 'not-selecting'

            if @dateEnd.value is date
              @activeKnob = @dateEnd
              @clickedKnob = true
              @$calendar.addClass 'selecting-end'
              @$calendar.addClass 'selecting-start' if @dateStart.value is date
            else if @dateStart.value is date
              @activeKnob = @dateStart
              @clickedKnob = true
              @$calendar.addClass 'selecting-start'
            else
              @dateStart.set date
              @dateEnd.set date
              @activeKnob = @dateEnd
              @$calendar.addClass 'selecting-start'
              @$calendar.addClass 'selecting-end'
          event.preventDefault()
          event.stopPropagation()
        return

      @$calendar.on 'mouseover', 'td', shiftAdd = (event) =>
        return unless (tgt = event.currentTarget) and date = @calendar.cellToDate tgt
        unless date%100
          return unless @onMonth
          startDate = date+1
          endDate = date+dates.daysInMonth(date)

          @dateEnd.set endDate if !(current = @dateEnd.value) or current < endDate
          @dateStart.set startDate if !(current = @dateStart.value) or current > startDate
        else
          return if !@activeKnob or @activeKnob.value is date
          @clickedKnob = false

          if @activeKnob is @dateStart

            if date > (dateEnd = @dateEnd.value)
              @dateStart.set dateEnd
              @activeKnob = @dateEnd
              @$calendar.removeClass 'selecting-start'
              @$calendar.addClass 'selecting-end'
            else
              @$calendar.toggleClass 'selecting-end', dateEnd is date

          else

            if date < (dateStart = @dateStart.value)
              @dateEnd.set dateStart
              @activeKnob = @dateStart
              @$calendar.addClass 'selecting-start'
              @$calendar.removeClass 'selecting-end'
            else
              @$calendar.toggleClass 'selecting-start', dateStart is date

          @activeKnob.set date

        return

