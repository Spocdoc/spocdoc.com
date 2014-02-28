_ = require 'lodash-fork'
dates = require 'dates-fork'
debug = global.debug 'app:tag_search:make_spec'

regexSpace = ///^#{_.regexp_s}+///
regexQuote = /^"((?:[^"\\]|\\.)*)"/
regexWord = ///^(.+?)(?=#{_.regexp_s}|$)///

regexLongMeta = ///^&([^:]+):(.+?[^\\#{_.regexpWhitespace}])&///
regexMeta = ///^&? ([^:#{_.regexpWhitespace}]+) : (#{_.regexp_S}+) ///

regexTag = ///^\#(?=([^\##{_.regexpWhitespace}#{_.regexp_punct}]+))\1(?:([^\#]*[^\\#{_.regexpWhitespace}])\#)?///
regexPerson = ///^@(?=([^@#{_.regexpWhitespace}#{_.regexp_punct}]+))\1(?:([^@]*[^\\#{_.regexpWhitespace}])@)?///

space = {type:'space', src: ' '}

module.exports = (src) ->
  out = []

  loop
    src = src.substring cap[0].length if cap

    # remove leading space
    if cap = regexSpace.exec src
      src = src.substring cap[0].length
      out.push
        type: 'space'
        src: cap[0]

    break unless src

    if cap = regexQuote.exec src
      out.push
        type: 'text'
        src: cap[0]
        value: cap[1]
      continue

    if cap = regexTag.exec src
      out.push
        type: 'tag'
        src: cap[0]
        value: cap[1] + (cap[2]||'')
      continue

    if cap = regexMeta.exec src
      elem =
        type: 'meta'
        src: cap[0]
        key: key = cap[1]
        value: value = cap[2]
      switch key
        when 'date'
          [elem['start'],elem['end']] = parsed = dates.strRangeToDateRange value
          elem['invalid'] = true if !parsed[0]
      out.push elem
      continue

    if cap = regexPerson.exec src
      out.push
        type: 'person'
        src: cap[0]
        value: cap[1] + (cap[2]||'')
      continue

    if cap = regexPerson.exec src
      out.push
        type: 'person'
        src: cap[0]
        value: cap[1]
      continue

    if cap = regexWord.exec src
      out.push
        type: 'text'
        src: cap[0]
        value: cap[1]
      continue

    debug "error parsing source at [#{src}]"
    out.push
      type: 'text'
      src: src
      value: src
    break

  return out

module.exports['update'] = update = (part, value) ->
  if part.type is 'meta'
    invalid = true
    if value.constructor is String
      invalid = false
    else
      switch part.key
        when 'date'
          value = dates.dateRangeToStrRange(part['start'] = value['start'], part['end'] = value['end'])
          invalid = false

    if invalid
      part['invalid'] = true
      value ||= ''
    else
      delete part['invalid']

    if ~value.indexOf(' ') || (part.key and ~part.key.indexOf(' '))
      value = value.replace(/\x20*$/,'')
      part.src = "&#{part.key}:#{value}&"
    else
      part.src = "#{part.key}:#{value}"
  else if part.type is 'tag'
    if ~value.indexOf(' ')
      value = value.replace(/\x20*$/,'')
      part.src = "#" + value + "#"
    else
      part.src = "#" + value
  else
    part.src = ''+value

  part.value = value
  part

module.exports['meta'] = (key, obj) ->
  update {type: 'meta', key: key}, obj

module.exports['space'] = space

module.exports['tag'] = (value) ->
  update { type: 'tag' }, value


