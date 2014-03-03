tumblr = require 'tumblr.js'

module.exports = (oauthDetails, cb) ->
  try
    client = new tumblr.Client
      consumer_key: 'prbOiPsVCzuOxEeUxV4iz0jpfB4uEhvgs7GuDsTYRVbnTXHXul'
      consumer_secret: 'BtIjlFliS7gSU4diz4y3vjoWpwQXvxXrGNXtiKytdgYcEaX2T7'
      token: oauthDetails.access
      token_secret: oauthDetails.secret

    client.userInfo (err, user) ->
      return cb err if err?
      return cb new Error("empty user") unless user
      cb null,
        username: user.name
        email: null
        name: null

  catch _error
    cb _error

  return
