regexEmail = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/
tagUtils = require '../tags'
dates = require 'dates-fork'
hash = require 'hash-fork'
Html = require 'marked-fork/html'
ObjectID = require('mongo-fork').ObjectID

getObjectID = (id) ->
  return id if id instanceof ObjectID
  if id._id
    id = id._id
  else if id._oid
    id = id._oid
  new ObjectID ''+id

module.exports =
  falsy: falsy = (str) ->
    str = (''+str).toLowerCase().trim()
    for prefix in ['no','f','0']
      if str.lastIndexOf(prefix,0) is 0
        return true
    false

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

  localUrl: (href) ->
    return unless href
    if href isnt mod = href.replace(/^https?:\/\//, '')
      href = mod
      if href isnt mod = href.replace(/^[^/]*(?:synop.si|spocdoc.com)[\/]*/, '')
        return "/#{mod}"
      else
        return
    if href.charAt(0) is '/'
      return if href.charAt(1) is '/'
      href
    else
      "/#{href}"
    
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

  makePublic: makePublic = (meta) ->
    isPublic = false

    if meta.hasOwnProperty('public') and !falsy(meta['public'])
      isPublic = true

    if meta.hasOwnProperty('private')
      isPublic = falsy(meta['private'])

    isPublic

  makeHtml: makeHtml = (src, editors_, otherMeta=0) ->
    html = new Html src

    if otherMeta
      if title = otherMeta['title']
        html.addMeta 'title', title
      if tags = otherMeta['tags']
        html.addTags tags

    # TODO add editors as meta
    html

  imgId: (b64) -> hash(b64).substr(0,24)

  makeDoc: (src, editors_, otherMeta=0) ->
    if src instanceof Html
      html = src
    else
      html = makeHtml src, editors_, otherMeta

    meta = html.meta
    custom = html.custom

    modified = new Date()
    if date = otherMeta['date'] or meta['date']
      unless date instanceof Date
        date = new Date date
        date = undefined if isNaN date.getTime()

    created = date or modified
    date = dates.dateToNumber(created)

    title = meta['title'] or ''
    tags = tagUtils['forIndexing'] Object.keys(meta['tags'])

    editors = []
    if Array.isArray editors_
      for editor, i in editors_
        editors[i] = getObjectID editor
    else
      editors[0] = getObjectID editors_

    return {
      'text': html.src
      'tags': tags
      'date': date # creation date as a number
      'modified': modified
      'created': created
      'words': meta['words']
      'title': title
      'custom': custom
      'public': makePublic meta
      'editors': editors
      'css': meta['css'] or ''
    }
