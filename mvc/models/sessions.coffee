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
    @run 'readOrCreate', (code, doc) ->
      if code is 'd'
        @serverCreate OJSON.fromOJSON(doc)
      else if code is 'r'
        @serverDelete()
        @error.set doc || "can't read"
      return

  invite: (details, cb) ->
    debugger
    console.log OJSON.toOJSON(details) # TODO DEBUG
    debugger
    @run 'invite', details, (code) =>
      if ok = code is 'o'
        @Model.reread()
        @get('user').set user = @Model['users'].read arguments[1]
        cb null, user
      else
        cb (code is 'r' && arguments[1]) || "Error logging in"

  login: (username, password, cb) ->
    @run 'login', {username, password}, (code) =>
      if ok = code is 'o'
        @Model.reread()
        @get('user').set user = @Model['users'].read arguments[1]
        cb null, user
      else
        cb (code is 'r' && arguments[1]) || "Error logging in"

  logout: (cb) ->
    @cookies.unset('session')
    @session.set @constructor.create {}
    @Model.reread()

