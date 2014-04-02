debug = global.debug 'app:calendar'
dates = require 'dates-fork'

firstSunday = (date) ->
  day = date.getDay()
  date = date.getDate()
  ((date + (7-day) - 1)%7)+1

dateToNumber = dates.dateToNumber

module.exports = class Calendar

  constructor: (@prefix, @$calendar, @nonEmptyOutlet, today=new Date()) ->
    @year = today.getFullYear()
    @month = today.getMonth()
    @daysPerMonth = dates.daysPerMonth(@year)
    @days = @daysPerMonth[@month]

    @nonEmpty = {}

    date = today.getDate()
    day = today.getDay()

    @today = dateToNumber today

    @firstSunday = firstSunday(today)
    @cumBlockWeeks = []
    @cumWeeks = 0
    @years = []
    @color = 0

    if date >= @firstSunday
      # advance to next month, so when the previous is rendered, it's rendering this month in color 0
      if ++@month > 11
        ++@year
        @month = 0
        @daysPerMonth = dates.daysPerMonth(@year)
      @firstSunday = 1+((@firstSunday - 1 + 7 - (@days % 7))%7)
      @days = @daysPerMonth[@month]
      @color = 1

      @['bottomBlock'] = @makeBlock()
    else
      # render the previous month. today will be on the stub of the last week
      @['bottomBlock'] = @makeBlock()

    neIteration = 0
    @nonEmptyOutlet.addOutflow =>
      nonEmpty = @nonEmpty
      newValue = @nonEmptyOutlet.value || 0
      ds = @['dateStart']
      ++neIteration
      for n in newValue
        @dateTo$Cell(n).addClass 'non-empty' if (n >= ds) and !nonEmpty[n]
        nonEmpty[n] = neIteration
      for k,v of nonEmpty when v isnt neIteration
        @dateTo$Cell(k).removeClass 'non-empty'
        delete nonEmpty[k]
      return

  @prototype['dateTo$Cell'] = @prototype.dateTo$Cell = (date) ->
    @$calendar.find("##{@prefix}#{date}")

  @prototype['$today'] = -> @dateTo$Cell @today

  @prototype['cellToDate'] = (cell) -> +cell.id.substr(@prefix.length)


  getHighlight: (start, end) ->
    return 0 if !start or !end

    outDates = []
    outMonths = []
    datesEnd = []

    year = start/10000|0
    month = start%10000/100|0
    date = start%100

    daysPerMonth = dates.daysPerMonth(year)
    days = daysPerMonth[month]

    d = start
    e = end

    # lazy (programmer) approach to adding dates from previous Saturday to end
    unless e is @today
      eDate = dates.numberToDate end
      sDate = dates.numberToDate start
      while eDate.getDay() isnt 6 and +eDate isnt +sDate
        datesEnd.push dateToNumber(eDate)
        eDate.setDate eDate.getDate()-1
      e = dates.dateToNumber eDate

    ey = e/10000|0
    em = e%10000/100|0
    ed = e%100

    while d <= e
      if date > days
        d += -date + 1 + 100
        date = 1
        if ++month > 11
          d += -month*100 + 10000
          month = 0
          ++year
          daysPerMonth = dates.daysPerMonth(year)
        days = daysPerMonth[month]

      if date is 1
        if ey > year or em > month or e is @today or ed is days
          sunday = firstSunday(new Date(year, month, date))
          while date < sunday
            outDates.push d
            ++d; ++date

          if e is @today or dates.daysPerMonth(ey)[em] is ed
            endD = e/100|0
          else
            endD = ey*100 + (em-1)
            endD -= 88 if em is 0

          d = (d-sunday)/100

          loop
            outMonths.push d
            break if d is endD
            if ++month > 11
              month = 0
              ++year
              daysPerMonth = dates.daysPerMonth(year)
            d = 100*year + month

          d *= 100
          days = daysPerMonth[month]
          tmp = (new Date(year,month,days)).getDay()
          d += date = 1 + days - (if tmp < 6 then tmp+1 else 0)
          continue

      outDates.push d

      ++d
      ++date

    outDates.push datesEnd.reverse()...

    return { start, end, dates: outDates, months: outMonths }

  @prototype['highlightDates'] = (start, end) ->
    end = @today if end > @today

    oldHighlight = @oldHighlight || 0
    highlight = @getHighlight start, end

    unless highlight.start is oldHighlight.start
      @dateTo$Cell(highlight.start).addClass 'range-start'
      @dateTo$Cell(oldHighlight.start).removeClass 'range-start'

    unless highlight.end is oldHighlight.end
      @dateTo$Cell(highlight.end).addClass 'range-end'
      @dateTo$Cell(oldHighlight.end).removeClass 'range-end'

    k = 0
    while ++k <= 2
      if k is 1
        jh = oldHighlight.dates || 0
        ih = highlight.dates || 0
      else
        jh = oldHighlight.months || 0
        ih = highlight.months || 0

      i = j = -1
      iD = jD = 0

      loop
        if iD < jD
          @dateTo$Cell(iD).addClass 'range'
          iD = ih[++i] || Infinity
        else if jD < iD
          @dateTo$Cell(jD).removeClass 'range'
          jD = jh[++j] || Infinity
        else unless isFinite iD
          break
        else
          iD = ih[++i] || Infinity
          jD = jh[++j] || Infinity

    @oldHighlight = highlight
    return

  @prototype['yearFromTop'] = (cell) ->
    search = @cumWeeks - cell
    
    min = 0
    max = @cumBlockWeeks.length-1
    mid = 0

    while mid < max
      if @cumBlockWeeks[mid] < search
        min = mid
      else
        max = mid
      mid = Math.ceil(min + (max - min)/2)

    @years[mid]

  _prevMonth: ->
    if --@month < 0
      @month = 11
      --@year
      @daysPerMonth = dates.daysPerMonth(@year)

    @firstSunday = 1 + ((@firstSunday - 1 + (@days = @daysPerMonth[@month])) % 7)
    @color ^= 1
    return

  @prototype['makeBlock'] = @prototype.makeBlock = ->
    oldFirstSunday = @firstSunday
    oldYear = @year
    @_prevMonth()

    today = @today
    year = @year
    month = @month
    date = @firstSunday
    @['dateStart'] = d = (id = (year*100+month)*100)+date

    days = if today - d < 50 then today%100 else @days
    weeks = (days - @firstSunday + 7)/7|0

    color = @color
    html = ""

    week = 0

    while week < weeks
      if week is 0
        row = """<td unselectable="on" class="month" id="#{@prefix}#{id}" rowspan="#{weeks}">#{dates.monthNames[month]}</td>"""
      else
        row = ''

      for [1..7]
        if date > days
          flipColor = true
          d += -date + 1 + 100
          date = 1
          if ++month > 11
            d += -month*100 + 10000
            month = 0
            ++year
          days = Infinity

        if d > today
          row += '<td class="future"></td>'
        else
          row += """
            <td unselectable="on" id="#{@prefix}#{d}" data-date="#{d}"
            class="#{if flipColor then " othermonth" else ''}#{if @nonEmpty[d] then ' non-empty' else ''}"
            ><div>#{date}</div></td>
            """

        ++date
        ++d

      html += """<tr#{if week is 0 and month is 0 then " class='year-start'" else ''}><div>#{row}</div></tr>"""
      ++week

    html = """<tbody id="#{@prefix}#{id/100}" class="color#{color}">#{html}</tbody>"""

    @cumBlockWeeks.push @cumWeeks += weeks
    @years.push @year

    return {
      'id': "#{@prefix}#{id/100}"
      'html': html
      'weeks': weeks
    }
