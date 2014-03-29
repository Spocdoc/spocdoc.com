ObjectID = require('mongo-fork').ObjectID
Reject = require 'ace_mvc/lib/error/reject'
debug = global.debug 'app:mediators:docs'

module.exports = (Base) ->
  class Handler extends Base
    create: (doc, cb) ->
      super

    read: (id, version, query, limit, sort, cb) ->
      # return cb.reject "Invalid session" unless @session.invited or @session.usersPriv
      if id
        if Array.isArray id
          super id, version, query, limit, sort, cb, (query, next) =>
            next null, @queryVisible(query)
        else
          super id, version, query, limit, sort, cb, (doc, next) =>
            return next() if doc.public

            if (userId = @session.userId) and editors = doc.editors
              for editor in editors when ''+editor is userId
                return next()

            next new Reject 'NOTVISIBLE'
      else # query
        super id, version, query, limit, sort, cb, (spec, next) =>
          spec.query = @queryVisible spec.query
          next null, spec

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

    distinct: (query, key, cb) ->
      super query, key, cb, (query, next) =>
        next null, @queryVisible query


# ===========================================

    queryVisible: (query) ->
      if userId = @session.userId
        $or = [ {public: true}, { editors: new ObjectID(userId) }]
      else
        $or = [ {public: true} ]

      if original$or = query.$or
        delete query.$or
        query.$and = [
          { $or: original$or },
          { $or: $or }
        ]
      else
        query.$or =$or

      query



