oauth = require 'connect_oauth'
debug = global.debug 'app:oauth'
utils = require '../../../lib/utils'

serviceNames =
  evernote: 'Evernote'
  twitter: 'Twitter'
  github: 'GitHub'
  linkedin: 'LinkedIn'
  tumblr: 'Tumblr'

module.exports =
  mixins:
    'mixins/editable val': [ 'email' ]

  inlets: [
    'emailError'
    'oauthError'
  ]

  outlets: [
    'email'
  ]

  $emailError: 'text'
  $oauthError: 'text'
  $email: 'text'

  $evernote: link: ['startOauth', 'evernote']
  $twitter: link: ['startOauth', 'twitter']
  $github: link: ['startOauth', 'github']
  $linkedin: link: ['startOauth', 'linkedin']
  $tumblr: link: ['startOauth', 'tumblr']

  $emailForm: link: ['submitEmail']

  outletMethods: [
    (inWindow) ->
      if inWindow
        @$email.focus()
      return

    (oauthError) ->
      @$oauth.toggleClass 'has-error', !!oauthError
      return
    (emailError) ->
      @$emailGroup.toggleClass 'has-error', !!emailError
      return
    (email) ->
      @emailError.set undefined
      @$submit.toggleClass 'can-submit', !!email
      return
  ]

  submitEmail: ->
    return if @emailError.value or @inviting
    email = @email.value

    unless utils.checkEmail email
      @$submit.removeClass 'can-submit'
      @emailError.set "This is not a valid email address"
      return

    @inviting = true
    @session.get().invite {email: email}, (err, user) =>
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

  startOauth: (service) ->
    return if @inviting

    $li = @$[service].parent()
    $li.addClass 'in-progress'

    @$oauth.removeClass 'has-error'

    oauth.startOauth service, (err, info) =>
      $li.removeClass 'in-progress'

      debug "oauth got err,info",err,info
      console.log "oauth got err,info",err,info

      if err? or !info
        @$oauth.addClass 'has-error'
        @oauthError.set "Connecting with #{service} failed. Try another service, or try email."
      else
        @$oauth.removeClass 'has-error'
        @inviting = true
        @session.get().invite info, (err, user) =>
          delete @inviting

          if err
            switch err
              when "NO_EMAIL"
                @info = info
                @depute 'toggleDialog', 'missingEmail', true
                return
              when "DUP_EMAIL"
                break
              else
                @oauthError.set "Oops! There was an internal error. We're looking into it. Please try again later."
                return

          @depute 'toggleDialog', 'youreInvited', true

      return


