Twit = require 'twit'

makeTwit = (oauthDetails) ->
  new Twit
    consumer_key: 'wpeHXSNTLF8j1cCLvjgQ3g'
    consumer_secret: '6n2FEfUUasGyf1HCI9hAs5i13CrJnju80CRleYl0E'
    access_token: oauthDetails.access
    access_token_secret: oauthDetails.secret

module.exports =
  getUser: (oauthDetails, cb) ->
    makeTwit(oauthDetails).get "users/show",
      user_id: oauthDetails.id
      (err, user) ->
        return cb err if err?
        return cb new Error("empty user") unless user

        cb null,
          username: user.screen_name
          email: null
          name: user.name
    return

  verifyId: (oauthDetails, cb) ->
    makeTwit(oauthDetails).get "account/verify_credentials",
      (err, info) ->
        return cb err if err?
        return cb new Error("empty user") unless info

        if info.id_str isnt oauthDetails.id
          cb new Error("bad user")
        else
          cb null
    return
