module.exports =
  inlets: [
    'fraction'
  ]

  outletMethods: [
    (fraction) ->
      @$meter.css 'width', "#{100*fraction}%"
  ]
