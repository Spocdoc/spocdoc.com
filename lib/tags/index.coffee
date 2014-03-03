module.exports =
  'forIndexing': (tags) ->
    seen = {}
    out = []

    for tag in tags
      tag = tag.toLowerCase()
      continue if seen[tag]
      sub = ''
      for part in tag.split '/'
        sub = sub + '/' + part
        tag = sub.substr 1
        unless seen[tag]
          out.push tag
          seen[tag] = 1
    out

  'getDisplayTags': (tags, map, list) ->
    out = []

    j = 0
    i = tags.sort().length
    lastTag = ''
    while --i >= 0
      tag = tags[i]
      if lastTag.lastIndexOf(tag + '/',0)
        out[j++] = tag
      lastTag = tag

    for tag, i in out = map.map out
      out[i] = list.case tag

    out

  'getSearchTags': (tags, map) -> map['search'] tags

  'tagsToObject': (globals, tags, exclude) ->
    if priv = globals['session'].get('user')?.get('priv')?.get()
      tags = priv['getDisplayTags'] tags

    if exclude
      tmp = exclude
      exclude = {}
      for tag in tmp
        exclude[tag.toLowerCase()] = 1
    else
      exclude = 0

    root = {}
    for tag in tags when !exclude[tag.toLowerCase()]
      obj = parent = root
      for part, i in parts = tag.split '/'
        parent = obj ||= parent[parts[i-1]] = {}
        obj = obj[part] ||= 0

    root

