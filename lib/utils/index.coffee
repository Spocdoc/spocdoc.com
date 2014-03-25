_ = require 'lodash-fork'
crypto = require 'crypto'

hash = (str) -> crypto.createHash('sha1').update(str).digest("hex")
secret = 'X,.1$$K$Z,G%rT3&PG-v?Jg#i7#...P$_ZD_D#E.'

module.exports = obj = require './browser'

_.extend obj,
  checksum: checksum = (str) -> hash "#{str}#{secret}"

  validateCookie: validateCookie = (cookie) -> cookie[1] is checksum cookie[0]
  validateDocCookie: (id, cookie) -> validateCookie cookie && id.toString() is cookie[0]
  makeCookie: (id) ->
    sessId = id.toString()
    clientChecksum = checksum sessId
    [sessId, clientChecksum]

  randomPassword: ->
    length = 24
    crypto.createHash('sha1').update(crypto.randomBytes(length)).digest('hex').substr(0,length)


