Evernote = require('evernote').Evernote

module.exports = (oauthDetails, cb) ->
  try
    token = oauthDetails.access
    client = new Evernote.Client token: token
    userStore = client.getUserStore()
    userStore.getUser token, (err, user) ->
      return cb err if err?
      return cb new Error("empty user") unless user

      cb null,
        username: user.username,
        email: user.email,
        name: user.name

  catch _error
    cb _error

  return
