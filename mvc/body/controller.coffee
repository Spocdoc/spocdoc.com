DOC_ABOUT = '6507bdb347de85cf373121da'

module.exports =
  outlets: [
    'page'
    'searchFrozen': -> !(@page.get() in ['search','blog','updates'])
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
  $content: (page) -> @getController page
  $landing: (page) -> !!(page in ['landing',''])

  showPage: (page) ->
    @view.toggleMenu 'on', false
    @getController page # for the side-effects... bad form
    @page.set page
    @closeDialog()
    return

  showDoc: (docId, startOffset, endOffset, carat) ->
    return unless docId
    @lastDoc.set docId
    (controller = @getController('docs')).id.set docId
    if startOffset? and endOffset?
      controller.initialPosition.set {startOffset, endOffset, carat}
    controller.controllers.field.search.set ''
    @showPage 'docs'
    return

  getController: (which) ->
    switch which
      when 'landing', ''
        @controllers['landing'] ||= new @View['body/landing'] this, 'landing', deputy: @view

      when 'import'
        controller = @controllers[which] ||= new @View['dialog'] this, which,
          title: 'Import'
          content: @controllers['importContent'] ||= new @Controller['body/import'] this, 'importContent', deputy: @view

      when 'inviteMe', 'youreInvited', 'missingEmail', 'hello'
        controller = @controllers['inviteMe'] ||= new @View['dialog'] this, "inviteMe",
          small: true

        switch which
          when 'inviteMe'
            controller.title.set 'Sign up'
            controller.content.set @controllers['inviteMeContent'] ||= new @View['body/invite_me'] this, 'inviteMeContent', deputy: @view
          when 'youreInvited'
            controller.title.set ''
            controller.content.set @controllers['youreInvitedContent'] ||= new @View['body/invite_me/youre_invited'] this, 'youreInvitedContent', deputy: @view
          when 'hello'
            controller.title.set 'Hello!'
            controller.content.set @controllers['helloContent'] ||= new @View['body/invite_me/hello'] this, 'helloContent', deputy: @view
          when 'missingEmail'
            controller.title.set 'No email'
            controller.content.set content = @controllers['missingEmailContent'] ||= new @View['body/invite_me/missing_email'] this, 'missingEmailContent', deputy: @view
            # quick hack to pass state from one to the other...
            if main = @controllers['inviteMeContent']
              content.info = main.info

        controller
      when 'docs'
        controller = @controllers['docs'] ||= new @Controller['docs'] this, 'docs'
        unless controller.id.value
          controller.id.set @lastDoc.value
        controller
      when 'about'
        controller = @controllers['static'] ||= new @Controller['docs'] this, 'static', id: =>
          switch @page.get()
            when 'about'
              DOC_ABOUT
            else
              controller.id.value
        controller
      when 'search','blog','updates'
        @controllers['search'] ||= new @Controller['search'] this, 'search', frozen: @searchFrozen
      when 'contactUs'
        @controllers['contactUs'] ||= new @View['contact_us'] this, 'contactUs'
      else
        null

  closeDialog: (which) -> @view.toggleDialog()

