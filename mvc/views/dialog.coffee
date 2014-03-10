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

  constructor: ->
    @$root.on 'focus', 'input', (event) =>
      if @$root.hasClass('small') and (elem = event.target).scrollIntoView
        elem.scrollIntoView()
      return

