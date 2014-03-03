request = require 'request'
makeUrl = require('url').format

module.exports = (oauthDetails, cb) ->
  try

    url = makeUrl
      protocol: 'https'
      hostname: 'api.linkedin.com'
      pathname: 'v1/people/~:(email-address,formatted-name)'
      query:
        oauth2_access_token: 'AQWBG0Na7IdZBFxbsvznVXfAXqxzOzXG7iMlaw3EdWSKpvkyVrv6dNpu2z0cHKM5XSwfAG61FSW16hxuK0w_xVNglvs2btclxu7YuyiTs4cdnhc1HWlghBUjphF-JWlcZBc2MGG3gs2LRKjszYjTydKIAfQ-LMDP6GiQ4iM5no9mvXAPZzs'
        format: 'json'

    request.get url, (err, res, user) ->
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

  catch _error
    cb _error

  return
