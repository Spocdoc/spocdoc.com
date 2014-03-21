request = require 'request'
makeUrl = require('url').format

apiUrl = (oauthDetails, pathname) ->
  makeUrl
    protocol: 'https'
    hostname: 'api.linkedin.com'
    pathname: pathname
    query:
      oauth2_access_token: oauthDetails.access
      format: 'json'

module.exports =
  getUser: (oauthDetails, cb) ->
    request.get apiUrl(oauthDetails, 'v1/people/~:(email-address,formatted-name)'), (err, res, user) ->
      try
        return cb err if err?
        return cb new Error("empty user") unless user
        user = JSON.parse user

        username = if profile = user.publicProfileUrl then profile.replace /.*\//, '' else null

        cb null,
          username: username
          email: user.emailAddress
          name: user.formattedName

      catch _error
        cb _error

    return

  verifyId: (oauthDetails, cb) ->
    request.get apiUrl(oauthDetails, 'v1/people/~:(id)'), (err, res, user) ->
      try
        return cb err if err?
        return cb new Error("empty user") unless user
        user = JSON.parse user

        if user.id isnt oauthDetails.id
          cb new Error("bad user")
        else
          cb null
      catch _error
        cb _error

    return

