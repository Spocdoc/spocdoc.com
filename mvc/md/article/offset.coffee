getOffset = (pos) ->
  node = pos['container']

  i = pos['offset']
  while --i >= 0
    if attr = (prev = node.childNodes[i]).getAttribute? 'data-md-offset'
      return (0|attr) + $(node)['textOffset'] {'container': node, 'offset': i}, pos

  offset = $(node)['textOffset'] pos

  if attr = node.getAttribute? 'data-md-offset'
    return (0|attr) + offset

  offset + getOffset
    'container': node.parentNode
    'offset': $['getChildIndex'] node

module.exports = (pos) ->
  node = pos['container']

  if $['isText'] node
    pos['offset'] + getOffset
      'container': node.parentNode
      'offset': $['getChildIndex'] node
  else
    getOffset pos

