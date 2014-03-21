##
# getUser:
# Given service oauth details, gets the email address, name, username associated with the
# account for different oauth providers.
#
# verifyId:
# Uses the oauth details and the service's API to verify that the oauth
# corresponds to the id in the details
##

path = require 'path'
providersPath = path.resolve __dirname, 'providers'

getProvider = (oauthDetails) ->
  try
    providerPath = path.resolve providersPath, oauthDetails.provider

    # service name shouldn't go into parent directories
    if 0 is providerPath.lastIndexOf(providersPath + "/", 0)
      return require(providerPath)

  catch _error

  null

module.exports = obj = {}

for method in ['getUser', 'verifyId']
  obj[method] = (oauthDetails, cb) ->
    if provider = getProvider(oauthDetails)
      try
        provider[method] oauthDetails, cb
      catch _error
        cb _error
    else
      cb new Error("invalid provider")
    return
