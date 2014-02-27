module.exports =
  getController: (which) ->
    @controllers['inviteMe'] ||= new @View['dialog'] this, "inviteMe",
      title: 'Invite Me!'
      small: true
      content: new @View['body/invite_me'] this, 'inviteMeContent'

  closeDialog: (which) -> @view.toggleDialog()


