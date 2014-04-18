request = require 'request'
async = require 'async'

apiCall = (oauthDetails, pathname, params, cb) ->
  ARGS = 4
  if (len = arguments.length) < ARGS
    cb = arguments[len-1]
    arguments[len-1] = null

  params ||= {}

  root = "https://api.angel.co"
  headers =
    Authorization: "Bearer #{oauthDetails.access}"
    'User-Agent': 'curl/7.30.0'
    Accept: 'application/json'
  request
    url: "#{root}/#{pathname}"
    headers: headers
    qs: params
    cb
  return

module.exports =
  name: -> 'AngelList'

  getUser: (oauthDetails, cb) ->
    apiCall oauthDetails, "1/me", (err, res, body) ->
      try
        return cb err if err?
        return cb new Error("empty user") unless body

        body = JSON.parse body
        oauthId = ''+oauthId if oauthId = oauthDetails.id
        bodyId = ''+bodyId if bodyId = body['id']

        unless bodyId is oauthId and bodyId
          cb new Error("bad user")
        else
          cb null,
            email: email = body.email or null
            username: null
            name: body.name or null
      catch _error
        cb _error
    return

  verifyId: (oauthDetails, cb) ->
    apiCall oauthDetails, "1/me", (err, res, body) ->
      try
        return cb err if err?
        return cb new Error("empty user") unless body

        body = JSON.parse body
        oauthId = ''+oauthId if oauthId = oauthDetails.id
        bodyId = ''+bodyId if bodyId = body['id']

        unless bodyId is oauthId and bodyId
          cb new Error("bad user")
        else
          cb null
      catch _error
        cb _error
