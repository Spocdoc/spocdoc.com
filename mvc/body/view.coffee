oauth = require 'connect_oauth'
oauthLib = require '../../lib/oauth'
debug = global.debug 'app:oauth'
utils = require '../../lib/utils'
constants = require '../constants'

tabs = [
  'admin'
  'blog'
  'explore'
  'connect'
  'docs'
  'search'
]

module.exports =
  mixins:
    'mixins/editable val': [ 'username', 'password' ]

  outlets: [
    'landing'
    'menu'
    'dialog'
    'content'
    'tab'
    'showDocs'
    'showAdmin'
    'plusContent': (loggedIn) ->
        @controllers['plus'] ||= new @View['body/plus'] this, 'plus'

  ]

  internal: [
    'dialogView'
    'usernameError': (username) ->
    'passwordError': (password) ->
    'submitError'
    'username'
    'password'
    'oauthError'
    'loggedIn': -> @ace.loggedIn
    'name': -> @user.get('name')
    'userImg': -> @user.get('picture')
  ]

  $content: 'viewPrepend'
  $menuButton: linkdown: ['toggleMenu', 'on']
  $menuButtonOverlay: linkdown: ['toggleMenu', 'on']
  $userMenu: linkup: ['toggleMenu', 'user']
  $userMenuOverlay: linkup: ['toggleMenu', 'user']
  $nameBack: linkdown: ['toggleMenu','user']
  $logIn: linkup: ['toggleMenu', 'login']
  $logInOverlay: linkup: ['toggleMenu', 'login']
  $logInBack: linkdown: ['toggleMenu','login']
  $inviteMe1: linkdown: ['toggleDialog','inviteMe']
  $inviteMe2: linkdown: ['toggleDialog','inviteMe']
  $dialog: view: 'dialogView'
  $name: 'text'
  $nameHeading: 'text': 'name'

  $import: linkup: ['toggleDialogMenu','import', true, 'user', false]

  $plusContent: 'view'
  $plusOverlay: linkup: ['toggleMenu', 'plus']
  $plus: linkup: ['toggleMenu', 'plus']

  $blog: linkdown: ['depute','showPage','blog']
  $explore: linkdown: ['depute','showPage','explore']
  $admin: linkdown: ['depute','showPage','admin']
  $connect: linkdown: ['depute','showPage','connect']
  $docs: linkdown: ['depute','showPage','docs']
  $search: linkdown: ['depute','showPage','search']
  $logo: linkdown: ['depute','showPage','']

  # footer links
  $company: link: ['depute','showDoc',constants.docCompany]
  $help: link: ['depute','help']

  # log in
  $submit: link: ['submitLogin']
  $usernameError: 'text'
  $passwordError: 'text'
  $submitError: 'text'
  submitLogin: ->
    username = @username.get()
    password = @password.get()
    @submitError.set ''
    @oauthError.set ''
    @$submitDiv.addClass 'in-progress'

    @session.get().logIn {username, password}, (err, user) =>
      @$submitDiv.removeClass 'in-progress'

      if err?
        switch err.code
          when 'USERNAME'
            @usernameError.set "We couldn't find this username."
            @$username.select()
            return
          when 'EMAIL'
            @usernameError.set "We couldn't find this email."
            @$username.select()
            return
          when 'PASSWORD'
            @passwordError.set "This password didn't match."
            @$password.select()
            return
          when 'NOTACTIVE'
            @submitError.set "Your invitation hasn't been activated yet."
            return
          when 'INVITED'
            [invitedId, inviteToken] = err.msg
            @depute 'doInvite', invitedId, inviteToken
            err = null
          when 'USEOAUTH'
            if name = oauthLib.name err.msg
              @username.set ''
              @password.set ''
              @submitError.set "Log in using #{name} (above) instead."
              return
        if err?
          @submitError.set "Oops! There was an internal error. We're looking into it. Please try again later."
          return

      @password.set ''
      @$username.blur()
      @$password.blur()
      @toggleMenu 'login', false
  

  # oauth
  $google: link: ['startOauth', 'google']
  # $evernote: link: ['startOauth', 'evernote']
  # $twitter: link: ['startOauth', 'twitter']
  # $github: link: ['startOauth', 'github']
  # $linkedin: link: ['startOauth', 'linkedin']
  # $tumblr: link: ['startOauth', 'tumblr']
  $oauthError: 'text'

  # log out 
  $logOut: link: ['logOut']
  logOut: -> @session.get()?.logOut (err) => @toggleMenu 'user', false

  toggleMenu: (which, toggleOn) ->
    menu = @menu.get() || ''

    if menu is menuNew = menu.replace ///(?:^|\s+)#{which}(?:$|\s+)///g, ' '
      # currently off
      return if toggleOn? and !toggleOn
      menu = menu.split(' ').concat(which).join(' ')
    else
      return if toggleOn? and toggleOn
      menu = if menuNew is ' ' then '' else menuNew

    @menu.set menu
    return

  toggleDialogMenu: (dialog, toggleDialog, menu, toggleMenu) ->
    @toggleDialog dialog, toggleDialog
    @toggleMenu menu, toggleMenu
    return

  toggleDialog: (which, toggleOn) ->
    which ||= ''

    if toggleOn?
      if toggleOn
        @dialog.set which
      else
        @dialog.set ''
    else
      if @dialog.get() is which
        @dialog.set ''
      else
        @dialog.set which
    return

  outletMethods: [
    (userImg) ->
      if userImg
        if local = utils.localUrl userImg
          uploadsServerRoot = @ace.manifest.uploadsServerRoot
          userImg = uploadsServerRoot + "/1" + local
        @$userImg.attr 'src', userImg
      else
        @$userImg.attr 'src', @templates.transparentGif
      return


    (landing) ->
      @$root.toggleClass 'landing', !!landing

    (usernameError) -> @$usernameGroup.toggleClass 'has-error', !!usernameError
    (passwordError) -> @$passwordGroup.toggleClass 'has-error', !!passwordError
    (submitError) -> @$submitDiv.toggleClass 'has-error', !!submitError
    (usernameError, username, passwordError, password) -> @$submit.toggleClass 'can-submit', !!(username and !usernameError and password and !passwordError)

    (loggedIn) ->
      @$root.toggleClass 'logged-out', !loggedIn
      @$root.toggleClass 'logged-in', !!loggedIn
      return

    (oauthError) -> @$oauth.toggleClass 'has-error', !!oauthError

    (menu) ->
      menu ||= ''

      @$root.attr 'data-menu',menu

      if @loggedIn.value and ///(?:^|\s)plus(?:$|\s)///.test menu
        if editor = @controllers['plus']?.controllers['article']?.getEditor()
          $.selection editor.offsetToPos(0), editor.offsetToPos(0)
      else if !$.mobile and ///(?:^|\s)login(?:$|\s)///.test menu
        @$username.select()
      return

    (dialog) ->
      @dialogView.set dialog = if dialog then @depute('getController',dialog) else null
      blur = !!dialog

      @$bar.toggleClass 'blurred', blur
      @$content.toggleClass 'blurred', blur
      @$footer.toggleClass 'blurred', blur

    # separated for server render
    (dialog, inWindow) ->
      if inWindow
        body = ($body = @$root.closest('body'))[0]

        # would prefer to prevent the body from scolling but doing this causes the scrollbar to disappear, so the content shifts
        # $body.toggleClass 'no-scroll', !!dialog

        unless @addedEvents
          @addedEvents = true

          $body.on 'keydown', (event) =>
            return unless event.target is body
            if (content = @content.value) and content.keydown
              content.keydown event
            return

          $body.on 'keyup', (event) =>
            return unless event.target is body
            if (content = @content.value) and content.keyup
              content.keyup event
            return

      return

    (tab) ->
      for t in tabs
        @$[t].toggleClass 'selected', !!(t is tab)

      # don't show the footer if there's a fixed position element
      # showFooter = !tab or tab in ['contactUs','admin']
      # @$footer.toggleClass 'hidden', !showFooter
      return

    (showDocs) -> @$docs.toggleClass 'hidden', !showDocs
    (showAdmin) -> @$admin.toggleClass 'hidden', !showAdmin

  ]

  startOauth: (service) ->
    return if @inviting

    $li = @$[service].parent()
    $li.addClass 'in-progress'

    @oauthError.set ''
    @submitError.set ''

    oauth.startOauth service, (err, info) =>
      debug "oauth got err,info",err,info

      if err? or !info
        @$oauth.addClass 'has-error'
        @oauthError.set "Connecting with #{oauthLib.name service} failed. Try again later."
        $li.removeClass 'in-progress'
      else
        @$oauth.removeClass 'has-error'
        @inviting = true
        @session.get().logIn info, (err) =>
          $li.removeClass 'in-progress'
          delete @inviting

          if err?
            switch err.code
              when "NOTACTIVE"
                @oauthError.set "Your invitation hasn't been activated yet."
              when 'INVITED'
                [invitedId, inviteToken] = err.msg
                @depute 'doInvite', invitedId, inviteToken
                err = null
              when "NOTFOUND"
                @oauthError.set "We don't have an account with you through #{oauthLib.name service}."
              else
                @oauthError.set "Oops! There was an internal error. We're looking into it. Please try again later."
            if err?
              return

          @toggleMenu 'login', false

      return

