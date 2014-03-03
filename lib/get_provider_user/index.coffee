##
# Given service oauth details, gets the email address, name, username associated with the
# account for different oauth providers.
##

path = require 'path'
providersPath = path.resolve __dirname, 'providers'

module.exports = (oauthDetails, cb) ->

  providerPath = path.resolve providersPath, oauthDetails.provider

  # service name shouldn't go into parent directories
  if -1 is providerPath.lastIndexOf(providersPath + "/", 0)
    return cb "Invalid provider"

  try
    require(providerPath) oauthDetails, cb
  catch _error
    return cb "Invalid provider"



