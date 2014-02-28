secret = 'X,.1$$K$Z,G%rT3&PG-v?Jg#i7#...P$_ZD_D#E.'

hash = (str) -> require('crypto').createHash('sha1').update(str).digest("hex")
diff = require "diff-fork"
callback = require "ace_mvc/lib/db/callback"
mongodb = require 'mongo-fork'
DBRef = mongodb.DBRef
ObjectID = mongodb.ObjectID
debug = global.debug "ace:app:sessions"
debugError = global.debug "error"
async = require 'async'
OJSON = require 'ojson'

checksum = (sessId) -> hash "#{sessId}#{secret}"

validateCookie = (cookie) ->
  cookie[1] is checksum cookie[0]

validateDocCookie = (id, cookie) ->
  validateCookie cookie && id.toString() is cookie[0]

makeCookie = (id) ->
  sessId = id.toString()
  clientChecksum = checksum sessId
  [sessId, clientChecksum]

coll = 'sessions'

DRAFT_TEXT = """
Edit me! 

 - just edit this text
 - uses [markdown](@spocdoc/1)
 - drag in pictures
 - completes \\#tags you've used and \\@people you know

#example
"""

module.exports = (Base) ->
  class Handler extends Base
    doSubscribe: (c, id) ->
      return super unless c is coll
      if @sock.isListening
        channel = @db.constructor.channel(coll, id)
        unless @sock.isListening @db, channel
          @sock.listenOn @db, channel, (args) =>
            @sock.listenOff @db, channel if args[1] is 'delete'
            return if args[0] is @sock.id

            # updates aren't guaranteed in order
            # BUT the only permitted op wrt the user key is addition
            if args[1] is 'update' and ops = OJSON.fromOJSON args[5]
              for op in ops when op.k is 'user' and ref = op.v
                break

            fn = =>
              # now send to client
              @sock.emit.apply @sock, args[1..]

            if ref
              proxy = new callback.Read fn
              proxy.doc = (doc) =>
                @_setUsersPriv doc
                @_sendUserDocs null, doc
                fn()

              @dbRead 'users_priv', ref.oid, null, null, null, null, proxy
            else
              fn()

            return
      return

    cookies: (cookies, cb) ->
      return cb.ok() unless (cookie = cookies.session) and validateCookie cookie

      id = @session.sessId = cookie[0]

      cb = new callback.Read cb.cb

      cb.doc = (doc) =>
        return cb.ok() unless userId = doc.user?.oid.toString()
        cb.doc = (doc) =>
          @_setUsersPriv doc
          cb.ok()

        @dbRead 'users_priv', userId, 0, null, null, null, cb

      @dbRead coll, id, 0, null, null, null, cb

    create: (doc, cb) ->
      return cb.reject "can't authenticate via create" if doc.user
      return cb.reject "" if doc.cookie

      proxy = Object.create cb

      (@session.oldSessIds ||= {})[id] = 1 if id = @session.sessId
      @_setUsersPriv(null)

      proxy.ok = =>
        @session.sessId = doc._id.toString()
        cookie = makeCookie doc._id
        ops = diff doc, cookie, path: ['cookie']
        updateProxy = Object.create cb
        updateProxy.ok = -> cb.update doc._v, ops
        @baseUpdate coll, doc._id, doc._v, ops, updateProxy

      @baseCreate coll, doc, proxy

    update: (id, version, ops, cb) ->
      return unless @_checkSession id, cb

      cb.validate = (from, ops, to, next) =>
        if to.user and (!from.user or to.user.oid.toString() != from.user.oid.toString()) and to.user.oid.toString() isnt @session.usersPriv?._id.toString()
          next new Error("Bad user")
        else if to.invited and !from.invited
          next new Error("Can't set invited directly")
        else
          next()

      super

    # can only read previous or current session
    read: (id, version, query, limit, sort, cb) ->
      return unless @_checkSessionOld id, cb
      super

    # can only delete *previous* sessions
    delete: (id, cb) ->
      strId = ''+id
      if strId is @session.sessId or !@session.oldSessIds?[strId]
        return cb.reject "Invalid session"
      super

    run: (id, version, cmd, args, cb) ->
      return unless @_checkSession id, cb

      switch cmd
        when 'login' then @_loginUser args.username, args.password, cb
        when 'readOrCreate' then @_readOrCreate id, version, cb
        when 'checkInvite' then @_checkInvite args.inviteCode, cb
        when 'signup' then @_signupUser args.email, args.username, args.password, cb
        else super
      return

    _checkUser: (id, cb) ->
      if id and @session.usersPriv?._id.toString() is id.toString()
        true
      else
        cb.reject "Invalid user"
        false

    _checkInvite: (inviteCode, cb) ->
      proxy = Object.create cb
      # proxy.reject = (msg) -> cb.reject "Code
      # @baseRead 'users_priv', null, null, {invites: inviteCode}, 1, null, proxy

    _checkSession: (id, cb) ->
      if id and @session.sessId is id.toString()
        true
      else
        cb.reject "Invalid session"
        false

    _checkSessionOld: (id, cb) ->
      if id and (@session.sessId is id.toString() or @session.oldSessIds?[id])
        true
      else
        cb.reject "Invalid session"
        false

    _sendUserDocs: (user, usersPriv) ->
      @clientCreate 'users', user if user and !@isSubscribed 'users', user._id
      @clientCreate 'users_priv', usersPriv if usersPriv # always send
      return

    _setUsersPriv: (doc) ->
      if old = @session.usersPriv
        @sock.listenOff? @db, @db.constructor.channel('users_priv', old._id)

      @session.usersPriv = doc

      if doc
        incoming = []
        channel = @db.constructor.channel('users_priv', doc._id)
        @sock.listenOn? @db, channel, (args) =>
          switch args[1]
            when 'update'
              version = args[4]
              ops = OJSON.fromOJSON args[5]
              incoming[version] = ops
              while ops = incoming[@session.usersPriv._v]
                delete incoming[@session.usersPriv._v]
                @session.usersPriv = diff.patch @session.usersPriv, ops
                ++@session.usersPriv._v
            when 'delete'
              @sock.listenOff? @db, channel
              delete @session.usersPriv
          # now send to client
          return if args[0] is @sock.id
          @sock.emit.apply @sock, args[1..]
          return
      return

    _loginUser: (username, password, cb) ->
      if ~username.indexOf '@'
        async.waterfall [
          (next) =>
            proxy = Object.create cb
            proxy.reject = (msg) -> cb.reject "UNKNOWN_EMAIL"
            proxy.doc = (doc) ->
              return cb.reject "UNKNOWN_EMAIL" unless doc = doc[0]
              next null, doc
            @dbRead 'users_priv', null, null, {email: username}, 1, null, proxy
          (priv, next) =>
            return cb.reject "BAD_PASSWORD" unless priv.password is checksum password

            proxy = Object.create cb
            proxy.reject = (msg) -> cb.reject "DB_ERROR"
            proxy.doc = (doc) =>
              return cb.reject "DB_ERROR" unless doc = doc[0]
              @_setUsersPriv priv
              @_sendUserDocs doc, priv
              cb.ok doc._id.toString()

            @dbRead 'users', null, null, {_id: priv._id}, 1, null, proxy

        ]
      else
        async.waterfall [
          (next) =>
            proxy = Object.create cb
            proxy.reject = (msg) -> cb.reject "UNKNOWN_USERNAME"
            proxy.doc = (doc) -> next null, doc
            @dbRead 'users', null, null, {username}, 1, null, proxy

          (users, next) =>
            return cb.reject "UNKNOWN_USERNAME" unless user = users[0]

            proxy = Object.create cb
            proxy.reject = (msg) -> cb.reject "BAD_PASSWORD"
            proxy.doc = (docs) =>
              return cb.reject "BAD_PASSWORD" unless doc = docs[0]
              @_setUsersPriv doc
              @_sendUserDocs user, doc
              cb.ok user._id.toString()

            @dbRead 'users_priv', null, null, {_id: user._id, password: checksum password}, 1, null, proxy
        ]

    _signupUser: (email, username, password, cb) ->
      id = new ObjectID()

      user =
        _id: id
        _v: 1
        username: username
        priv: new DBRef 'users_priv', id

      userPriv =
        _id: id
        _v: 1
        password: checksum password
        email: email
        draft: DRAFT_TEXT
        draftSelection: [0, DRAFT_TEXT.length]
        draftFiller: ''

      async.waterfall [
        (next) =>
          proxy = new callback.Read -> cb.reject "DB_ERROR"
          proxy.doc = (doc) ->
            userPriv.lastDoc = doc.lastDoc
            next()

          @baseRead coll, @session.sessId, 0, null, null, null, proxy

        (next) =>
          @handlers['users_priv']._chooseDraftFiller next

        (fillerText, next) =>
          userPriv.draftFiller = fillerText

          cbUser = new callback.Create cb.cb
          cbUser.ok = next
          cbUser.reject = (err='') ->
            if /\bduplicate key\b/.test err
              if /\busers.\$username\b/.test err
                return cb.reject "DUP_USERNAME"
            debugError "Error creating user: #{err}"
            cb.reject "DB_ERROR"
          @baseCreate 'users', user, cbUser

        (next) =>
          cbUserPriv = new callback.Create cb.cb
          cbUserPriv.ok = =>
            @_setUsersPriv userPriv
            @_sendUserDocs user, userPriv
            cb.ok id
          cbUserPriv.reject = (err) =>
            if /\bduplicate key\b/.test(err) and /\busers_priv.\$email\b/.test(err)
              cb.reject "DUP_EMAIL"
            else
              debugError "Error creating user_priv: #{err}"
              cb.reject "DB_ERROR"

            deleteCb = new callback.Create ->
            @baseDelete 'users', id, deleteCb

          @baseCreate 'users_priv', userPriv, cbUserPriv
      ], (err) ->
        if err?
          debugError err
          cb.reject "DB_ERROR"
        return

    _readOrCreate: (id, version, cb) ->
      debug "_readOrCreate with id [",id,"] version [",version,"]"
      doc =
        _id: new ObjectID id.toString()
        _v: version + 1
        cookie: makeCookie id

      proxy = Object.create cb
      proxy.ok = => cb.doc doc
      proxy.reject = =>
        @baseRead coll, id, version, null, null, null, cb

      @baseCreate coll, doc, proxy


