request = require 'request'
async = require 'async'

apiCall = (oauthDetails, pathname, cb) ->
  root = "https://api.github.com"
  headers =
    Authorization: "token #{oauthDetails.access}"
    'User-Agent': 'curl/7.30.0'
  request
    url: "#{root}/#{pathname}"
    headers: headers
    cb
  return

module.exports =
  name: -> 'GitHub'

  getUser: (oauthDetails, cb) ->
    async.parallel
      email: (next) ->
        apiCall oauthDetails, "user/emails", (err, res, body) ->
          try
            return next err if err?
            return next new Error("empty user") unless body
            body = JSON.parse body
            next null, body[0] or null
          catch _error
            next _error

      user: (next) ->
        apiCall oauthDetails, "user", (err, res, body) ->
          try
            return next err if err?
            return next new Error("empty user") unless body
            body = JSON.parse body
            next null, username: body.login, name: body.name
          catch _error
            next _error

      (err, result) ->
        return cb err if err?
        cb null,
          username: result.user.username or null
          email: result.email or null
          name: result.user.name or null
    return

  verifyId: (oauthDetails, cb) ->
    apiCall oauthDetails, "user", (err, res, body) ->
      try
        return next err if err?
        return next new Error("empty user") unless body

        body = JSON.parse body

        if ''+body.id isnt ''+oauthDetails.id
          cb new Error("bad user")
        else
          cb null
      catch _error
        cb _error

