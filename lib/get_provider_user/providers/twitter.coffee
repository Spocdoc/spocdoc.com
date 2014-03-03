Twit = require 'twit'

module.exports = (oauthDetails, cb) ->
  try
    twitter = new Twit
      consumer_key: 'wpeHXSNTLF8j1cCLvjgQ3g'
      consumer_secret: '6n2FEfUUasGyf1HCI9hAs5i13CrJnju80CRleYl0E'
      access_token: oauthDetails.access
      access_token_secret: oauthDetails.secret

    twitter.get "users/show", user_id: oauthDetails.id, (err, user) ->
      return cb err if err?
      return cb new Error("empty user") unless user

      cb null,
        username: user.screen_name
        email: null
        name: user.name
  catch _error
    cb _error

  return
