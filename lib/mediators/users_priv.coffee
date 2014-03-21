async = require 'async'
debug = global.debug "ace:app:users_priv"
diff = require 'diff-fork'
Reject = require 'ace_mvc/lib/error/reject'

IMMUTABLE_FIELDS = [
  '_id'
  '_v'
  'email'
  'password'
]

module.exports = (Base) ->
  class Handler extends Base
    read: (id, version, query, limit, sort, cb) ->
      return cb new Reject 'BADUSER' unless @session.isUser id
      super

    update: (id, version, ops, cb) ->
      return cb new Reject 'BADUSER' unless @session.isUser id
      super id, version, ops, cb, (original, ops, doc, next) =>
        (return next new Reject 'NOEDIT') for op in ops when op.k in IMMUTABLE_FIELDS if ops
        next()

