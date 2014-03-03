DOC_ABOUT = '6507bdb347de85cf373121da'


module.exports =
  outlets: [
    'page'
  ]

  $tab: -> @page
  $content: (page) ->
    if page then @getController page else @controllers['landing'] ||= new @View['body/landing'] this, 'landing', deputy: @view

  showPage: (page) ->
    @page.set page
    @closeDialog()
    return

  getController: (which) ->
    switch which
      when 'inviteMe', 'youreInvited', 'missingEmail'
        controller = @controllers['inviteMe'] ||= new @View['dialog'] this, "inviteMe",
          small: true

        switch which
          when 'inviteMe'
            controller.title.set 'Invite Me!'
            controller.content.set new @View['body/invite_me'] this, 'inviteMeContent', deputy: @view
          when 'youreInvited'
            controller.title.set 'We\'ll invite you!'
            controller.content.set new @View['body/invite_me/youre_invited'] this, 'youreInvitedContent', deputy: @view
          when 'missingEmail'
            controller.title.set 'No email'
            controller.content.set new @View['body/invite_me/missing_email'] this, 'missingEmailContent', deputy: @view

        controller
      when 'docs'
        @controllers['docs'] ||= new @Controller['docs'] this, 'docs'
      when 'about'
        (controller = @getController('docs')).doc.set @Model['docs'].read DOC_ABOUT
        controller
      when 'contactUs'
        @controllers['contactUs'] ||= new @View['contact_us'] this, 'contactUs'
      else
        null

  closeDialog: (which) -> @view.toggleDialog()

