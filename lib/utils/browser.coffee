regexEmail = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/
tagUtils = require '../tags'
dates = require 'dates-fork'
Html = require 'marked-fork/html'

module.exports =
  defaultArr: (defaultTabs, orderedTabs) ->
    allTabs = {}
    (allTabs[tab] = 1 for tab in defaultTabs) if defaultTabs
    tabs = []
    if orderedTabs
      for tab in orderedTabs when allTabs[tab]
        delete allTabs[tab]
        tabs.push tab
    tabs.push tab for tab of allTabs
    tabs
    
  splitLengths: (arr, nRows) ->
    len = arr.length
    times = nRows - len

    while --times >= 0
      longest = 0
      i = 0
      j = -1
      while ++j < len
        if (k = arr[j]) >= longest
          longest = k
          i = j

      break if longest is 1

      rhs = (longest / 2)|0
      lhs = longest - rhs
      arr.splice(i, 1, lhs, rhs)
      ++len

    arr

  checkEmail: (email) -> !!regexEmail.test(email)

  makeDoc: (src) ->
    html = new Html src
    meta = html.meta
    custom = html.custom

    created = modified = new Date()
    date = dates.dateToNumber(created)
    tags = tagUtils['forIndexing'] Object.keys(meta['tags'])

    return {
      'text': src
      'tags': tags
      'date': date # creation date as a number
      'modified': modified
      'created': created
      'words': meta['words']
      'title': meta['title']
      'custom': custom
    }

