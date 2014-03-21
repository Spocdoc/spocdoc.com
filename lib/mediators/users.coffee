Reject = require 'ace_mvc/lib/error/reject'

IMMUTABLE_FIELDS = [
  '_id'
  '_v'
  'active'
]

module.exports = (Base) ->
  class Handler extends Base
    read: (id, version, query, limit, sort, cb) -> super

    update: (id, version, ops, cb) ->
      return cb new Reject 'BADUSER' unless @session.isUser id
      super id, version, ops, cb, (original, ops, doc, next) =>
        (return next new Reject 'NOEDIT') for op in ops when op.k in IMMUTABLE_FIELDS if ops
        next()

