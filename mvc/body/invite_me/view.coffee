oauth = require 'connect_oauth'
oauthLib = require '../../../lib/oauth'
debug = global.debug 'app:oauth'
utils = require '../../../lib/utils'

module.exports =
  mixins:
    'mixins/editable val': [ 'email' ]

  inlets: [
    'emailError'
    'oauthError'
    'submitError'
  ]

  outlets: [
    'email'
  ]

  $emailError: 'text'
  $oauthError: 'text'
  $submitError: 'text'

  $google: link: ['startOauth', 'google']
  $angellist: link: ['startOauth', 'angellist']
  # $evernote: link: ['startOauth', 'evernote']
  # $twitter: link: ['startOauth', 'twitter']
  # $github: link: ['startOauth', 'github']
  # $linkedin: link: ['startOauth', 'linkedin']
  # $tumblr: link: ['startOauth', 'tumblr']

  $emailForm: link: ['submitEmail']

  outletMethods: [
    (inWindow) ->
      if inWindow and !$.mobile
        @$email.focus()
      return

    (submitError) -> @$submitDiv.toggleClass 'has-error', !!submitError
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
    @submitError.set ''

    unless utils.checkEmail email
      @$submit.removeClass 'can-submit'
      @emailError.set "This is not a valid email address"
      return

    @inviting = true
    @session.get().invite {email: email}, (err) =>
      delete @inviting

      if err
        switch err.code
          when "DUP_EMAIL" then break
          else
            @submitError.set "Oops! There was an internal error. We're looking into it. Please try again later."
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

      debug "oauth got err,info",err,info

      if err? or !info
        @$oauth.addClass 'has-error'
        @oauthError.set "Connecting with #{oauthLib.name service} failed. Try another service, or try email."
        $li.removeClass 'in-progress'
      else
        @$oauth.removeClass 'has-error'
        @inviting = true
        @session.get().invite info, (err, invitedId, inviteToken) =>
          delete @inviting
          $li.removeClass 'in-progress'

          if err
            switch err.code
              when "DUPEMAIL" then break
              when "NOEMAIL"
                @info = info
                @depute 'toggleDialog', 'missingEmail', true
                return
              else
                @oauthError.set "Oops! There was an internal error. We're looking into it. Please try again later."
                return

          if invitedId and inviteToken
            @depute 'toggleDialog', 'inviteMe', false
            @depute 'doInvite', invitedId, inviteToken
          else
            @depute 'toggleDialog', 'youreInvited', true

      return


