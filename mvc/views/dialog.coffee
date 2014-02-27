module.exports =
  inlets: [
    'content'
    'title'
    'small'
  ]

  $content: 'view'
  $title: 'text'

  $close: link: -> ['depute', 'closeDialog', @aceName]

  outletMethods: [
    (small) -> @$root.toggleClass 'small', !!small
  ]

