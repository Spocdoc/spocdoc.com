async = require 'async'
debug = global.debug "ace:app:users_priv"
diff = require 'diff-fork'
_ = require 'lodash-fork'
utils = require '../../lib/utils'
Reject = require 'ace_mvc/lib/error/reject'
Conflict = require 'ace_mvc/lib/error/conflict'
mongodb = require 'mongo-fork'
ObjectID = mongodb.ObjectID

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

    run: (id, version, cmd, args, cb) ->
      return cb new Reject "NOUSER" unless @session.isUser id

      switch cmd
        when 'draftDone' then @draftDone id, version, cb
        else super
      return

# -------------------------------------------------

    draftDone: (id, version, cb) ->
      docId = null

      async.waterfall [
        (next) =>
          @_read 'users_priv', id, next

        (userPriv, next) =>
          return next new Reject 'NOUSER' unless userPriv
          return next new Conflict v unless version is v = userPriv._v

          draft = userPriv.draft or ''

          _.extend doc = utils.makeDoc(draft, userPriv._id, null),
            _id: docId = new ObjectID()
            _v: 1

          @_create 'docs', doc, next

        # (next) =>
        #   @_update 'users_priv', id, version, [{'o': 1,'k': 'draft','v': ''}], next

      ], (err) =>
        return cb err or new Reject 'NODOC' if err? or !docId
        cb null, docId

