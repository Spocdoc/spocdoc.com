mediator = require 'ace_mvc/mediator'
path = require 'path'
async = require 'async'
Reject = require 'ace_mvc/lib/error/reject'

class Session
  constructor: (@mediator) ->
    @oldSessIds = []

  isEditor: (doc) ->
    return false unless (editors = doc.editors) and userId = @userId
    for editor in editors when ''+editor is userId
      return true
    false

  toId: (id) -> ''+(id._id or id.oid or id or '')

  isUser: (id) ->
    return false unless id
    id = id._id if id._id
    id = id.oid if id.oid
    (userId = @userId) and id and userId is ''+id

  set: (id) ->
    id = id._id if id._id
    id = id.oid if id.oid

    @oldSessIds[old] = 1 if old = @sessId
    @sessId = ''+id
    return

  isSession: (id) -> @sessId is ''+id

  isOldSession: (id) -> !!@oldSessIds[id]

  isAnySession: (id) -> @isSession(id) or @isOldSession(id)

  read: (version, cb) ->
    if (len = arguments.length) < 2
      cb = arguments[len-1]
      arguments[len-1] = null

    return cb new Reject "NOSESS" unless id = @sessId
    @mediator._read 'sessions', id, version, (err, session) =>
      return cb new Reject 'NOSESS' if err? or !session
      cb err, session

  readUser: (cb) ->
    return cb new Reject "NOUSER" unless userId = @userId
    @mediator._read 'users', userId, (err, user) =>
      return cb new Reject 'NOUSER' if err? or !user
      cb err, user

  readUserPriv: (cb) ->
    return cb new Reject "NOUSER" unless userId = @userId
    @mediator._read 'users_priv', userId, (err, userPriv) =>
      return cb new Reject 'NOUSER' if err? or !userPriv
      cb err, userPriv

  # reads clientCreate on the user documents if set, then calls cb
  setUser: (user, userPriv, cb) ->
    ARGS = 3
    if (len = arguments.length) < ARGS
      cb = arguments[len-1]
      arguments[len-1] = null

    if userPriv
      if userPriv._id # it's a document
        id = userPriv._id
      else
        if userPriv.oid # it's a reference
          id = userPriv.oid
        else # it's an id
          id = userPriv
        userPriv = null
    if user
      if user._id # it's a document
        id = user._id
        unless user.priv # it's userPriv
          userPriv = user
          user = null
      else
        if user.oid # it's a reference
          id = user.oid
        else # it's an id
          id = user
        user = null

    unless id
      return cb new Reject 'NOUSER' unless id = @userId
    else
      @userId = id = ''+id

    # no-op if we're already subscribed
    if @mediator.subscribed('users', id) and @mediator.subscribed('users_priv',id)
      return cb()

    async.waterfall [
      (next) =>
        return next(null, user) if user
        @mediator._read 'users', id, next

      (user_, next) =>
        user = user_
        return next null, userPriv if userPriv
        @mediator._read 'users_priv', id, next

      (userPriv_, next) =>
        userPriv = userPriv_

        unless user and userPriv
          return next new Reject 'NOUSER'
        
        unless @mediator.subscribed 'users', id
          @mediator.clientCreate 'users', user

        unless @mediator.subscribed 'users_priv', id
          @mediator.clientCreate 'users_priv', userPriv

        next()

    ], cb


module.exports = mediator path.resolve(__dirname, '../lib/mediators'), Session


