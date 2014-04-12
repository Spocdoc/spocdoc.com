constants = require '../../constants'
SCROLL_PADDING = 0

module.exports =
  outlets: [
    'invitedId'
    'inviteToken'
  ]

  # $inviteMe3: link: ['depute','toggleDialog','inviteMe']
  # $findOutMore: link: ['depute','showPage','about']

  $downArrow: link: ['scrollFold']
  $marketing: view: -> new @View['md/article'] this,
    doc: @Model['docs'].read constants.docAbout

  outletMethods: [
    (invitedId, inviteToken) ->
      if invitedId and inviteToken
        @validateInvite()
        return
      return

    (inWindow) ->
      if inWindow and !@ace.onServer
        # set the headliner to take up the entire above-the-fold
        $window = $(global)
        @$headliner.height $window.height() - @$headliner.offset().top
        @$downArrow.css 'display', 'block'
      return

  ]

  scrollFold: ->
    top = @$headliner.offset().top + @$headliner.height()
    $scrollParent = @$scrollParent ||= @$root.scrollParent()
    $scrollParent.animate
      scrollTop: top - SCROLL_PADDING
      constants.scrollMillis


  validateInvite: ->
    if @validating
      @validateAgain = true
      return

    @validating = true
    @validateAgain = false

    invitedId = @invitedId.value
    inviteToken = @inviteToken.value

    @session.get()?.validateInvite invitedId, inviteToken, (err, user) =>
      @validating = false

      if err?
        @validateInvite() if @validateAgain
        return

      @validateAgain = false

      if user.get('active').get() # then already active
        @depute 'showPage', ''
      else
        @depute 'toggleDialog', 'hello', true
      return
    return

  constructor: ->
    unless @ace.onServer
      $window = $(global)
      $window.on 'resize', =>
        if @inWindow.value
          @$headliner.height $window.height() - @$headliner.offset().top
        return


