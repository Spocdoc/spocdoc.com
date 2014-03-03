emptyRegex = //
arr = []

module.exports = (escaped) ->
  return emptyRegex unless len = escaped.length

  j = 0; i = 0
  c2 = escaped.charAt(j++)
  c2 += escaped.charAt(j++) if c2 is '\\'
  p1 = ''

  str = "(?:\\b.?#{escaped.substr(j)}"

  len = escaped.length
  while j < len
    p2 = escaped.substring 0, j
    c1 = c2
    c2 = escaped.charAt(j++)
    c2 += escaped.charAt(j++) if c2 is '\\'

    if c1 is c2
      str += ")|(?:\\b#{p1}#{c1}.?#{c2}?#{escaped.substr(j)}"
    else
      str += ")|(?:\\b#{p1}(?:#{c2}#{c1}|#{c1}.?#{c2}?)#{escaped.substr(j)}"

    p1 = p2

  new RegExp str + ")"
