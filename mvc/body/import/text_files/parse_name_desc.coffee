_ = require 'lodash-fork'

regex = ///
(?:(y+)|(m+)|(d+)|(t+)|(\\\*+))
///gi

months =
  'jan': 0
  'feb': 1
  'mar': 2
  'apr': 3
  'may': 4
  'jun': 5
  'jul': 6
  'aug': 7
  'sep': 8
  'oct': 9
  'nov': 10
  'dec': 11

getMonth = (month) ->
  if /^\d+$/.test month
    +month-1
  else
    months[month.substr(0,3).toLowerCase()]

getYear = (year) ->
  year = +year
  if year < 1900
    year + 1900
  else
    year


module.exports = (desc) ->
  desc = _.regexpEscape desc

  groups = 0
  year = month = date = title = 0


  desc = desc.replace regex, (matched, y, m, d, t, star) ->
    if y
      year = ++groups

      if matched.length > 2
        '(\\d{4})'
      else if matched.length > 1
        '(\\d{2})'
      else
        '(\\d{2,4})'

    else if m
      month = ++groups

      if matched.length > 2
        '([A-Za-z]{3,9})'
      else if matched.length > 1
        '([A-Za-z]{3,9}|\\d{2})'
      else
        '([A-Za-z]{3,9}|\\d{1,2})'

    else if d
      date = ++groups

      if matched.length > 1
        '(\\d{2})'
      else
        '(\\d{1,2})'

    else if t
      title = ++groups
      '(.*?)'

    else if star
      '.*?'

  desc = new RegExp '^' + desc + '(?:\\.[^\\.]*)?$'

  (str) ->

    if cap = desc.exec str
      ret = {}
      if year or month or date
        now = new Date()

        y = if year then getYear(cap[year]) else now.getYear()
        m = if month then getMonth(cap[month]) else now.getMonth()
        d = if date then +cap[date] else now.getDate()

        return false unless 1900 < y < 2500 and 0 < d < 32 and 0 <= m <= 11

        ret['date'] = new Date y, m, d

      if title
        ret['title'] = cap[title]

      ret






