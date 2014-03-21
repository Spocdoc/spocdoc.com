Evernote = require('evernote').Evernote

getUser = (oauthDetails, cb) ->
  token = oauthDetails.access
  client = new Evernote.Client token: token
  userStore = client.getUserStore()
  userStore.getUser token, (err, user) ->
    return cb err if err?
    return cb new Error("empty user") unless user
    cb null, user
  return

module.exports =
  getUser: (oauthDetails, cb) ->
    getUser oauthDetails, (err, user) ->
      return cb err if err?
      cb null,
        username: user.username,
        email: user.email,
        name: user.name

  verifyId: (oauthDetails, cb) ->
    getUser oauthDetails, (err, user) ->
      return cb err if err?
      if ''+user.id isnt ''+oauthDetails.id
        cb new Error("bad user")
      else
        cb null
