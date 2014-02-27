REMOVE_MILLIS = 500

module.exports =
  inlets: [
    'slides'
    'emptySlide'
    'scrollTops'
  ]

  outlets: [
    'activeSlide'
  ]

  outletMethods: [
    (slides, emptySlide) ->
      newActive = if len = (if slides then slides.length else 0) then slides[len-1] else emptySlide
      return if @oldActive is newActive

      cell = @depute 'getCell', newActive, len-1
      if len >= (@oldLen ||= 0) then @pushTo cell else @popTo cell

      @activeSlide.set @oldActive = newActive
      @oldLen = len
      return
  ]

  pop: ->
    @slides.pop()

  push: (name) ->
    @slides.push name

  _makeHolder: (leftMargin) ->
    slides = @slides.value || 0
    index = (slides.length || 0) - 1
    if ~index and (headingHtml = @depute 'getHeadingHtml', slides[index] or emptySlide, index)? and headingHtml.constructor is String
      $cell = $ """<div class="slide" #{if leftMargin then "style='margin-left: #{leftMargin}'" else ''}><div class="heading"><a class="back"><span>back</span></a>#{headingHtml}</div></div>"""
      $cell.find('.back').link 'mousedown', this, 'pop'
    else
      $cell = $ """<div class="slide" #{if leftMargin then "style='margin-left: #{leftMargin}'" else ''}></div>"""

    $cell

  pushTo: (rhs) ->
    # @slides.push rhs.aceName

    if !@main?
      if @ace.booting and @template.bootstrapped
        @$main = $ @$root[0].firstChild
      else
        @$root.append @$main = @_makeHolder()

      (@main = rhs).appendTo(@$main, this)
    else
      @$main.after $rhs = @_makeHolder()
      rhs.appendTo($rhs, this)
      @$main.css 'margin-left', '-100%'

      $oldmain = @$main
      oldmain = @main
      @$main = $rhs
      @main = rhs

      global.setTimeout (=>
        if $oldmain[0].firstChild
          oldmain.detach()
          @depute 'freeCell', oldmain.aceName
        $oldmain.remove()
      ), REMOVE_MILLIS

    return

  popTo: (lhs) ->
    # return unless @slides.pop() and ~(index = @slides.length-1) and lhs = @depute 'getCell', @slides[index], index

    @$main.before $lhs = @_makeHolder "-100%"
    lhs.appendTo($lhs, this)
    $lhs.css 'margin-left' # hack to force it to render so the next step animates
    $lhs.css 'margin-left', '0'

    $oldmain = @$main
    oldmain = @main
    @$main = $lhs
    @main = lhs

    global.setTimeout (=>
      if $oldmain[0].firstChild
        oldmain.detach()
        @depute 'freeCell', oldmain.aceName
      $oldmain.remove()
    ), REMOVE_MILLIS
