# htmlPos = (container, targetOffset, thisOffset) ->
#   node = null
# 
#   for child in children = container.childNodes
#     if attr = child.getAttribute? 'data-md-offset'
#       attr |= 0
#       break if attr > targetOffset
#       node = child
#       thisOffset = attr
# 
#   if node
#     htmlPos node, targetOffset, thisOffset
#   else if pos = $(container)['textOffsetToPos'] targetOffset - thisOffset
#     return pos
#   else
#     or {
#       'container': 
#       'offset': 
#     }
# 
# module.exports = ($container, targetOffset) -> htmlPos $container[0], targetOffset, 0
module.exports = ($container, targetOffset) ->
