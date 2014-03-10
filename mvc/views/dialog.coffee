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
      scrollPadding = 100

      # don't use scrollIntoView -- it scrolls the fixed position *and* the body! -- BUGGY
      if @$root.hasClass('small') and elem = event.target
        $elem = $ elem
        if (delta = @$scrolling.height() + (scrollTop = @$scrolling.scrollTop()) - $elem.position().top) < scrollPadding
          @$scrolling.scrollTop scrollTop + scrollPadding - delta
      return

