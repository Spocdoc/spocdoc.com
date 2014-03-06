utils = require '../../../../lib/utils'

module.exports =
  mixins:
    'mixins/editable val': [ 'email' ]

  inlets: [
    'emailError'
  ]

  outlets: [
    'email'
  ]

  $emailError: 'text'
  $email: 'text'

  outletMethods: [
    (inWindow) ->
      if inWindow
        @$email.focus()
      return
    (emailError) ->
      @$emailGroup.toggleClass 'has-error', !!emailError
      return
    (email) ->
      @emailError.set undefined
      @$submit.toggleClass 'can-submit', !!email
      return
  ]

  $emailForm: link: ['submitEmail']

  submitEmail: ->
    return if @emailError.value or @inviting
    email = @email.value

    unless utils.checkEmail email
      @$submit.removeClass 'can-submit'
      @emailError.set "This is not a valid email address"
      return

    info = @info || {}
    info.email = email

    @inviting = true
    @session.get().invite info, (err, user) =>
      delete @inviting

      if err
        switch err
          when "DUP_EMAIL"
            break
          else
            @oauthError.set "Oops! There was an internal error. We're looking into it. Please try again later."
            return

      @depute 'toggleDialog', 'youreInvited', true
      @email.set '' # clear the form

    return
