module.exports =
  outlets: [
    'invitedId'
    'inviteToken'
  ]

  $inviteMe3: link: ['depute','toggleDialog','inviteMe']
  $findOutMore: link: ['depute','showPage','about']

  outletMethods: [
    (invitedId, inviteToken) ->
      if invitedId and inviteToken
        @validateInvite()
        return
      return
  ]

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

      if user.get('active').get() is 2 # then already active
        @depute 'showPage', ''
      else
        @depute 'toggleDialog', 'hello', true
      return
    return
