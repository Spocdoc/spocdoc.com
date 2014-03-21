tumblr = require 'tumblr.js'

makeClient = (oauthDetails) ->
  new tumblr.Client
    consumer_key: 'prbOiPsVCzuOxEeUxV4iz0jpfB4uEhvgs7GuDsTYRVbnTXHXul'
    consumer_secret: 'BtIjlFliS7gSU4diz4y3vjoWpwQXvxXrGNXtiKytdgYcEaX2T7'
    token: oauthDetails.access
    token_secret: oauthDetails.secret


module.exports =
  getUser: (oauthDetails, cb) ->
    makeClient(oauthDetails).userInfo (err, user) ->
      return cb err if err?
      return cb new Error("empty user") unless user
      cb null,
        username: user.name
        email: null
        name: null
    return

  verifyId: (oauthDetails, cb) ->
    makeClient(oauthDetails).userInfo (err, user) ->
      return cb err if err?
      return cb new Error("empty user") unless user
      cb(if ''+user.name isnt ''+oauthDetails.id then new Error("bad user") else null)
