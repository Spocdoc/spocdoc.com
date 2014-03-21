OJSON = require 'ojson'
Outlet = require 'outlet'
mongodb = require 'mongo-fork'
ObjectID = mongodb.ObjectID

module.exports =
  static:
    initSession: (ctx) ->
      ctx.session.set =>
        current = ctx.session.get()
        return current if current?.present.get()
        model = @readOrCreate ctx.cookies.get('session')?[0]
        model.present.get() # to add auto dependency
        model

      lastCookie = ctx.cookies.get('session')?[0]
      lastSession = undefined
      oldSessions = []
      cookieUpdater = ->
        session = ctx.session.get()
        cookie = session?.get('cookie')?.get()
        if session isnt lastSession
          oldSessions.push lastSession if lastSession
          lastSession = session
        unless cookie?[0] in [undefined, lastCookie]
          @cookies.set 'session', cookie
          lastCookie = cookie[0]
          oldSession.delete() for oldSession in oldSessions
          oldSessions.length = 0
        return

      ctx._sessionCookieUpdater = new Outlet cookieUpdater, ctx, true

    readOrCreate: (id) ->
      if @isValidId id
        unless (model = new this id).present.value
          model.readOrCreate()
        model
      else
        @create()

  readOrCreate: ->
    @run 'readOrCreate', (err, doc) =>
      if err?
        @serverDelete()
        @error.set "Can't read"
      else if doc
        @serverCreate doc
      return

  validateInvite: (invitedId, inviteToken, cb) ->
    @run 'validateInvite', {id: invitedId, token: inviteToken}, (err) =>
      return cb err if err?
      @get('user').set user = @Model['users'].read invitedId
      cb null, user

  acceptInvite: (args, cb) ->
    @run 'acceptInvite', args, cb

  invite: (details, cb) ->
    @run 'invite', details, cb

  login: (details, cb) ->
    @run 'login', details, (err, id) =>
      return cb err if err?
      @Model.reread()
      @get('user').set user = @Model['users'].read arguments[1]
      cb null, user

  logout: (cb) ->
    @cookies.unset('session')
    @session.set @constructor.create {}
    @Model.reread()

