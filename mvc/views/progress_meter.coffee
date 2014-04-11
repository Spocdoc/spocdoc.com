module.exports =
  inlets: [
    'fraction'
  ]

  outletMethods: [
    (fraction) ->
      @$meter.css 'width', "#{Math.ceil(100*fraction)}%"
  ]
