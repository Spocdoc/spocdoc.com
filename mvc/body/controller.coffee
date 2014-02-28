DOC_ABOUT = '6507bdb347de85cf373121da'


module.exports =
  outlets: [
    'page'
  ]

  $tab: -> @page
  $content: (page) ->
    if page then @getController page else @controllers['landing'] ||= new @View['body/landing'] this, 'landing', deputy: @view

  showPage: (page) -> @page.set page

  getController: (which) ->
    switch which
      when 'inviteMe'
        @controllers['inviteMe'] ||= new @View['dialog'] this, "inviteMe",
          title: 'Invite Me!'
          small: true
          content: new @View['body/invite_me'] this, 'inviteMeContent'
      when 'docs'
        @controllers['docs'] ||= new @Controller['docs'] this, 'docs'
      when 'about'
        (controller = @getController('docs')).doc.set @Model['docs'].read DOC_ABOUT
        controller
      else
        null

  closeDialog: (which) -> @view.toggleDialog()

