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

  isUser: (id) ->
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

  read: (cb) ->
    return cb new Reject "NOSESS" unless id = @sessId
    @mediator._read 'sessions', id, (err, session) =>
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

    # both user and userPriv are optional. distinguish with priv field
    if !userPriv? and user
      unless user.priv
        userPriv = user
        user = null

    # could pass an id, rather than a user document
    unless user
      if userPriv
        id = userPriv._id
      else
        return cb new Reject 'NOUSER' unless id = @userId
    else
      if user._id
        id = user._id
      else
        id = user; user = null
        id = id.oid if id.oid

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


