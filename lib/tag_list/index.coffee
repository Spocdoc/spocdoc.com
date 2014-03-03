# note: this is a strange implementation (doesn't just store an object
# directly) because MongoDB can't handle periods in object keys

module.exports = class TagList
  constructor: (tagList, tagCase) ->
    @update tagList, tagCase

  update: (tagList, tagCase) ->

    tags = @tags = {}
    for tag in @['tagList'] = @tagList = tagList || []
      tags[tag] = 1

    tc = @tc = {}
    for tag in @['tagCase'] = @tagCase = tagCase || []
      tc[tag.toLowerCase()] = tag
    return

  case: (tag) ->
    tc = @tc
    parts[i] = tc[part] || part for part, i in parts = tag.split '/'
    parts.join('/')

  add: (tag) ->
    modified = false
    tags = @tags
    tc = @tc
    tagCase = @tagCase

    t = ''
    for part,i in tag.split('/')
      if part isnt (lower = part.toLowerCase()) and !(part >= tc[lower])
        tagCase.push tc[lower] = part
        modified = true

      t = t + (if i then '/' else '') + lower
      unless tags[t]
        modified = true
        tags[t] = 1
        @tagList.push t

    modified
    
  remove: (tag) ->
    lower = tag.toLowerCase()
    return false unless tags[lower]
    slash = lower + '/'

    tl = @tagList

    i = 0
    for tag in tl
      if tag is lower or !tag.lastIndexOf(slash, 0)
        delete tags[tag]
      else
        tl[i++] = tag

    tl.length = i
    true
