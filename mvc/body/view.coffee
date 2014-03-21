tabs = [
  'about'
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
    'menu'
    'dialog'
    'content'
    'tab'
    'showDocs'

  ]

  internal: [
    'dialogView'
    'usernameError': (username) ->
    'passwordError': (password) ->
    'submitError'
    'username'
    'password'
  ]

  $content: 'view'
  $menuButton: linkdown: ['toggleMenu', 'on']
  $menuButtonOverlay: linkdown: ['toggleMenu', 'on']
  $logIn: linkup: ['toggleMenu', 'login']
  $logInOverlay: linkup: ['toggleMenu', 'login']
  $logInBack: linkdown: ['toggleMenu','login']
  $inviteMe1: linkdown: ['toggleDialog','inviteMe']
  $inviteMe2: linkdown: ['toggleDialog','inviteMe']
  $dialog: view: 'dialogView'

  $about: link: ['depute','showPage','about']
  $blog: link: ['depute','showPage','blog']
  $explore: link: ['depute','showPage','explore']
  $connect: link: ['depute','showPage','connect']
  $docs: link: ['depute','showPage','docs']
  $search: link: ['depute','showPage','search']
  $logo: link: ['depute','showPage','']
  $contactUs: link: ['depute','showPage','contactUs']

  # footer links
  $footAbout: link: ['depute','showPage','about']
  $footBlog: link: ['depute','showPage','blog']

  # log in
  $submit: link: ['submitLogin']
  $usernameError: 'text'
  $passwordError: 'text'
  submitLogin: ->
    username = @username.get()
    password = @password.get()
    @submitError.set ''
    @$submitDiv.addClass 'in-progress'

    @session.get().logIn {username, password}, (err, user) =>
      @$submitDiv.removeClass 'in-progress'

      if err?
        switch err.code
          when 'USERNAME'
            @usernameError.set "We couldn't find this username or email."
            @$username.select()
          when 'PASSWORD'
            @passwordError.set "This password didn't match."
            @$password.select()
          else
            @submitError.set "Oops! There was an internal error. We're looking into it. Please try again later."
        return
      @toggleMenu 'login', false
  
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
    (usernameError) -> @$usernameGroup.toggleClass 'has-error', !!usernameError
    (passwordError) -> @$passwordGroup.toggleClass 'has-error', !!passwordError
    (usernameError, username, passwordError, password) -> @$submit.toggleClass 'can-submit', !!(username and !usernameError and password and !passwordError)

    (menu) ->
      @$root.attr 'data-menu',(menu||'')

    (dialog) ->
      @dialogView.set dialog = if dialog then @depute('getController',dialog) else null
      blur = !!dialog

      $('body').toggleClass 'no-scroll', blur

      @$bar.toggleClass 'blurred', blur
      @$content.toggleClass 'blurred', blur
      @$footer.toggleClass 'blurred', blur

    (tab) ->
      for t in tabs
        @$[t].toggleClass 'selected', !!(t is tab)

      # don't show the footer if there's a fixed position element
      showFooter = !tab or tab is 'contactUs'
      @$footer.toggleClass 'hidden', !showFooter
      return

    (showDocs) -> @$docs.toggleClass 'hidden', !showDocs

  ]

