request = require 'request'
async = require 'async'

module.exports = (oauthDetails, cb) ->
  try
    root = "https://api.github.com"
    headers =
      Authorization: "token #{oauthDetails.access}"
      'User-Agent': 'curl/7.30.0'

    async.parallel
      email: (next) ->
        request
          url: "#{root}/user/emails"
          headers: headers
          (err, res, body) ->
            try
              return next err if err?
              return next new Error("empty user") unless body
              body = JSON.parse body
              next null, body[0] or null
            catch _error
              next _error
      user: (next) ->
        request
          url: "#{root}/user"
          headers: headers
          (err, res, body) ->
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
  catch _error
    cb _error

  return
