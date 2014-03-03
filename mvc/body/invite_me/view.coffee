oauth = require 'connect_oauth'
debug = global.debug 'app:oauth'

serviceNames =
  evernote: 'Evernote'
  twitter: 'Twitter'
  github: 'GitHub'
  linkedin: 'LinkedIn'
  tumblr: 'Tumblr'

module.exports =
  $evernote: link: ['startOauth', 'evernote']
  $twitter: link: ['startOauth', 'twitter']
  $github: link: ['startOauth', 'github']
  $linkedin: link: ['startOauth', 'linkedin']
  $tumblr: link: ['startOauth', 'tumblr']

  startOauth: (service) ->
    $li = @$[service].parent()
    $li.addClass 'in-progress'

    @$oauth.removeClass 'has-error'

    oauth.startOauth service, (err, info) =>
      $li.removeClass 'in-progress'

      debug "oauth got err,info",err,info
      console.log "oauth got err,info",err,info

      if err? or !info
        @$oauth.addClass 'has-error'
        @$oauthError.text "Connecting with #{service} failed. Try another service, or try email."
      else
        @$oauth.removeClass 'has-error'
        @session.get().invite info, (err, user) =>
          if err
            switch err
              when "NO_EMAIL"
                @depute 'toggleDialog', 'missingEmail', true
                return
              when "DUP_EMAIL"
                break
              else
                @$oauthError.text "Oops! There was an internal error. We're looking into it. Please try again later."
                return

          @depute 'toggleDialog', 'youreInvited', true

      return

