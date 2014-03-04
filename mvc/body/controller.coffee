DOC_ABOUT = '6507bdb347de85cf373121da'


module.exports =
  outlets: [
    'page'
  ]

  internal: [
    'lastDoc': ->
      if @ace.loggedIn.get()
        @session.get('user').get('priv')?.get('lastDoc')
      else
        @session.get('lastDoc')
  ]

  # show docs tab if lastDoc is set...
  $showDocs: -> @lastDoc

  $tab: -> @page
  $content: (page) ->
    if page then @getController page else @controllers['landing'] ||= new @View['body/landing'] this, 'landing', deputy: @view

  showPage: (page) ->
    @view.toggleMenu 'on', false
    @page.set page
    @closeDialog()
    return

  showDoc: (docId) ->
    return unless docId
    @lastDoc.set docId
    @getController('docs').id.set docId
    @showPage 'docs'
    return

  getController: (which) ->
    switch which
      when 'inviteMe', 'youreInvited', 'missingEmail'
        controller = @controllers['inviteMe'] ||= new @View['dialog'] this, "inviteMe",
          small: true

        switch which
          when 'inviteMe'
            controller.title.set 'Invite Me!'
            controller.content.set @controllers['inviteMeContent'] ||= new @View['body/invite_me'] this, 'inviteMeContent', deputy: @view
          when 'youreInvited'
            controller.title.set 'We\'ll invite you!'
            controller.content.set @controllers['youreInvitedContent'] ||= new @View['body/invite_me/youre_invited'] this, 'youreInvitedContent', deputy: @view
          when 'missingEmail'
            controller.title.set 'No email'
            controller.content.set content = @controllers['missingEmailContent'] ||= new @View['body/invite_me/missing_email'] this, 'missingEmailContent', deputy: @view
            # quick hack to pass state from one to the other...
            if main = @controllers['inviteMeContent']
              content.info = main.info

        controller
      when 'docs'
        controller = @controllers['docs'] ||= new @Controller['docs'] this, 'docs', id: =>
          controller.id.value or @lastDoc.value
        controller
      when 'about'
        controller = @controllers['static'] ||= new @Controller['docs'] this, 'static', id: =>
          switch @page.get()
            when 'about'
              DOC_ABOUT
            else
              controller.id.value
        controller
      when 'search','blog'
        @controllers['search'] ||= new @Controller['search'] this, 'search'
      when 'contactUs'
        @controllers['contactUs'] ||= new @View['contact_us'] this, 'contactUs'
      else
        null

  closeDialog: (which) -> @view.toggleDialog()

