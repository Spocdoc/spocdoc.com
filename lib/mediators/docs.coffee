Reject = require 'ace_mvc/lib/error/reject'

module.exports = (Base) ->
  class Handler extends Base
    create: (doc, cb) ->
      super

    read: (id, version, query, limit, sort, cb) ->
      # return cb.reject "Invalid session" unless @session.invited or @session.usersPriv
      super

    update: (id, version, ops, cb) ->
      super id, version, ops, cb, (original, ops, doc, next) =>
        return next new Reject 'NOEDIT' unless @session.isEditor original
        if !doc.editors or !doc.editors.length
          return next new Reject 'NOEDITORS'
        next()

    delete: (id, cb) ->
      super id, cb, (doc, next) =>
        return next new Reject 'NOEDIT' unless @session.isEditor doc
        next()

    distinct: (query, key, cb) -> super

