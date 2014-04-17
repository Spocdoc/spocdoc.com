utils = require '../../../../lib/utils'

module.exports =
  mixins:
    'mixins/editable val': [ 'username', 'name', 'password' ]

  inlets: [
    'nameError': (name) ->
    'usernameError': (username) ->
    'passwordError': (password) ->
    'submitError'
  ]

  outlets: [
    'username': -> @userPriv.get('prefUsername')
    'name': -> @user.get('name')
    'password'
    'requirePassword': -> !@userPriv.get('oauthTokens')?.get()
  ]

  $usernameError: 'text'
  $nameError: 'text'
  $passwordError: 'text'
  $submitError: 'text'
  $name: 'val'
  $username: 'val'
  $password: 'val'

  outletMethods: [
    (inWindow) -> @$name.focus() if inWindow

    # (name) -> @nameError.set undefined
    # (username) -> @usernameError.set undefined
    # (password) -> @passwordError.set undefined

    (nameError) -> @$nameGroup.toggleClass 'has-error', !!nameError
    (usernameError) -> @$usernameGroup.toggleClass 'has-error', !!usernameError
    (passwordError) -> @$passwordGroup.toggleClass 'has-error', !!passwordError
    (submitError) -> @$submitDiv.toggleClass 'has-error', !!submitError

    (name, username, password, usernameError, nameError, requirePassword, passwordError) ->
      if canSubmit = name and username and !usernameError and !nameError
        if requirePassword
          canSubmit = password and !passwordError

      @$submit.toggleClass 'can-submit', !!canSubmit

    (requirePassword) -> @$passwordGroup.toggleClass 'hidden', !requirePassword


  ]

  $helloForm: link: ['submitHello']

  submitHello: ->
    password = @password.get() or ''
    username = @username.get() or ''
    name = @name.get() or ''
    id = @user.get()?.id

    unless id
      @submitError.set 'There was an error. Try reloading the page.'
      return

    @submitError.set ''

    if @requirePassword.get()
      unless utils.validPassword password
        @$password.select()
        return @passwordError.set utils.passwordError
    unless utils.validUsername username
      @$username.select()
      return @usernameError.set utils.usernameError

    @session.get()?.acceptInvite {id, name, username, password}, (err, docId) =>
      if err?
        switch err.code
          when "USERNAME"
            @usernameError.set "This username is taken."
            @$username.select()
          when "PASSWORD"
            @upasswordError.set "Password is required."
            @$password.select()
          else
            @submitError.set "Oops! There was an internal error. We're looking into it. Please try again later."
        return

      @depute 'toggleDialog', 'hello', false
      @depute 'showDoc', docId if docId
    return

  constructor: ->
    @$helloForm.on 'focus', 'input', ->
      $(this).closest('.input-group').addClass 'selected'
      return

    @$helloForm.on 'blur', 'input', ->
      $(this).closest('.input-group').removeClass 'selected'
      return
