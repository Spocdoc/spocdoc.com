_ = require 'lodash-fork'
TEXT_NODE = 3

makeDom = (type, src, invalid) ->
  if type is 'space'
    $.textNode src
  else
    $.parseHTML("""<span class="#{type}#{if invalid then " invalid" else ''}">#{_.unsafeHtmlEscape src}</span>""")[0]

regexType = /(?: |^)(text|tag|meta|person)(?: |$)/
regexInvalid = /(?: |^)(invalid)(?: |$)/
classToType = (className) -> cap[1] if cap = regexType.exec className
classToInvalid = (className) -> regexInvalid.test className

module.exports = (spec, dom) ->
  nodeInvalid = specInvalid = specType = node = nodeText = nodeType = undefined
  specSrc = ''; nodeOffset = specOffset = nodeLen = 0; i = -1; nSpecs = spec.length

  unless spec.length
    dom.innerHTML = '<br>'
    return

  nextNode = ->
    if node = (if node then node.nextSibling else dom.firstChild)
      nodeOffset += nodeLen
      nodeText = node.nodeValue ? node.textContent ? node.innerText
      nodeLen = nodeText.length
      if node.nodeType is TEXT_NODE
        nodeType = 'space'
        nodeInvalid = false
      else
        nodeType = classToType node.className
        nodeInvalid = classToInvalid node.className
    else
      nodeOffset = Infinity
      nodeLen = 0
    return

  nextSpec = ->
    if ++i >= nSpecs
      specOffset = Infinity
    else
      specOffset += specSrc.length
      {'type': specType, 'src': specSrc, 'invalid': specInvalid} = spec[i]
    return

  nextNode()
  nextSpec()

  loop
    while specOffset < nodeOffset
      specDom = makeDom(specType, specSrc, specInvalid)
      if node then dom.insertBefore(specDom, node) else dom.appendChild specDom
      nextSpec()

    while isFinite nodeOffset

      if nodeOffset + nodeLen <= specOffset or specType isnt nodeType
        prevNode = node
        nextNode()
        dom.removeChild prevNode
        continue

      if nodeText isnt specSrc
        if nodeType is 'space'
          node.nodeValue = specSrc
        else
          node.innerHTML = _.unsafeHtmlEscape specSrc

      if !!nodeInvalid isnt !!specInvalid
        $(node).toggleClass 'invalid', !!specInvalid

      nextSpec()
      nextNode()

    break unless isFinite specOffset

  return

