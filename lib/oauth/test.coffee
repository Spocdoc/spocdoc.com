#!/usr/bin/env coffee

oauth = require './'
oauthDetails =
  provider: 'angellist'
  id: 521143
  access: '4f527a80ff4a271885e249a17b2933ae'

oauth.verifyId oauthDetails, (err, data) ->
  console.log arguments
