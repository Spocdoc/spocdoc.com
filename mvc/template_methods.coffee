module.exports =
  'setProgress': (fraction, meter) ->
    # because manually editing style.width is problematic on the server (would
    # require property defs for all the style types)
    $(meter.firstChild).css 'width', "#{100*fraction}%"

