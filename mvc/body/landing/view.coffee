constants = require '../../constants'
HEADLINER_MARGIN = 64

module.exports =
  # $inviteMe3: link: ['depute','toggleDialog','inviteMe']
  # $findOutMore: link: ['depute','showPage','about']

  $downArrow: link: ['scrollFold']
  $marketing: view: -> new @View['md/article'] this,
    doc: @Model['docs'].read constants.docAbout

  outletMethods: [
    (inWindow) ->
      if inWindow and !@ace.onServer
        # set the headliner to take up the entire above-the-fold
        $window = $(global)
        @$headliner.height $window.height() - @$headliner.offset().top
        @$downArrow.css 'display', 'block'
      return

  ]

  scrollFold: ->
    top = @$headliner.height()
    $scrollParent = @$scrollParent ||= @$root.scrollParent()
    $scrollParent.animate
      scrollTop: top + HEADLINER_MARGIN
      constants.scrollMillis


  constructor: ->
    unless @ace.onServer
      $window = $(global)
      $window.on 'resize', =>
        if @inWindow.value
          @$headliner.height $window.height() - @$headliner.offset().top
        return


