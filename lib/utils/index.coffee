_ = require 'lodash-fork'
crypto = require 'crypto'
{ObjectID} = require 'mongo-fork'
Html = require 'marked-fork/html'


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

  # takes existing full doc and converts it into a fork
  makeFork: (doc, editor) ->
    doc.fork_id = doc._id
    doc.fork_v = doc._v
    doc._v = 1
    doc._id = new ObjectID()

    # ensure the forked document is private
    if doc.text
      html = new Html doc.text
      html.removeMeta 'public'
      html.removeMeta 'private'

    # ensure only editor has authorship
    if id = editor
      id = id._id if id._id
      id = id.oid if id.oid
      try
        id = new ObjectID(''+id)
      catch _error
        id = null
    doc.editors = [id] if id

    doc



