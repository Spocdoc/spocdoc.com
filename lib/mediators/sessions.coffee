utils = require '../utils'
diff = require "diff-fork"
mongodb = require 'mongo-fork'
DBRef = mongodb.DBRef
ObjectID = mongodb.ObjectID
Reject = require 'ace_mvc/lib/error/reject'
async = require 'async'
OJSON = require 'ojson'
oauth = require '../oauth'

debug = global.debug "ace:app:sessions"
debugError = global.debug "error"

module.exports = (Base) ->
  class Handler extends Base
    cookies: (cookies, cb) ->
      return cb() unless (cookie = cookies.session) and utils.validateCookie cookie

      @session.set sessId = cookie[0]

      async.waterfall [
        (next) => @_read 'sessions', sessId, next
        (session, next) =>
          @session.setUser user if user = session.user
          next null
      ], cb

    create: (doc, cb) ->
      return cb new Reject "INVALID" if doc.user or doc.cookie

      @_create 'sessions', doc, (err) =>
        return cb err if err?

        @session.set sessId = ''+doc._id

        cookie = utils.makeCookie sessId
        ops = diff doc, cookie, path: ['cookie']

        @_update 'sessions', sessId, doc._v, ops, (err) =>
          return cb err if err?
          cb null, doc._v, ops

    update: (id, version, ops, cb) ->
      return cb new Reject "NOSESSION" unless @session.isSession id
      super id, version, ops, cb, (from, ops, to, next) =>
        if to.user and !@session.isUser(to.user)
          next new Reject "NOUSER"
        else
          next()

    # can only read previous or current session
    read: (id, version, query, limit, sort, cb) ->
      return cb new Reject "NOSESSION" unless @session.isAnySession id
      super

    # can only delete *previous* sessions
    delete: (id, cb) ->
      return cb new Reject "NOSESSION" unless @session.isOldSession id
      super

    run: (id, version, cmd, args, cb) ->
      return cb new Reject "NOSESSION" unless @session.isSession id

      switch cmd
        when 'readOrCreate' then @readOrCreate id, version, cb
        when 'invite' then @invite args, cb
        when 'validateInvite' then @validateInvite args.id, args.token, cb
        when 'acceptInvite' then @acceptInvite args, cb
        when 'logIn' then @logIn args, cb
        else super
      return

# -------------------------------------------------

    readOrCreate: (id, version, cb) ->
      debug "readOrCreate with id [",id,"] version [",version,"]"

      doc =
        _id: new ObjectID(''+id)
        _v: version + 1
        cookie: utils.makeCookie id

      @_create 'sessions', doc, (err) =>
        if err?
          @_read 'sessions', id, version, cb
        else
          cb null, doc

    invite: (details, cb) ->
      user = userPriv = id = undefined

      async.waterfall [
        (next) =>
          # email is required
          unless details.email
            oauth.getUser details, (err, userDetails) ->
              return next new Reject "NOEMAIL" if err? or !userDetails?.email
              details.email = userDetails.email
              details.username ||= userDetails.username
              details.name ||= userDetails.name
              next()
          else
            next()

        (next) =>
          id = new ObjectID()

          user =
            _id: id
            _v: 1
            username: " #{id}" # prefix with space so it's otherwise an invalid user
            priv: new DBRef 'users_priv', id
            active: 0

          userPriv =
            _id: id
            _v: 1
            email: details.email
            created: new Date()
            invite: utils.randomPassword()

          if details.username
            userPriv.prefUsername = details.username

          if details.provider
            userPriv.oauth =
              provider: details.provider
              id: details.id
              access: details.access
              secret: details.secret
              refresh: details.refresh

          @session.read next

        (session, next) =>
          userPriv.lastDoc = lastDoc if lastDoc = session.lastDoc
          @_create 'users', user, next

        (next) =>
          @_create 'users_priv', userPriv, (err) =>
            if err?
              @_delete 'users', id, ->
              err ||= ''
              # duplicate email -- means the user exists already.  not an error
              err = null if /\bduplicate key\b/.test(err) and /\busers_priv.\$email\b/.test(err)
              next err
            else
              next()
      ], cb

    validateInvite: (id, token, cb) ->
      async.waterfall [
        (next) =>
          @_read 'users_priv', id, next

        (userPriv, next) =>
          return next new Reject "INVALID" if userPriv.invite isnt token
          @session.setUser userPriv
          @session.sendUserDocs userPriv, cb

      ], cb

    acceptInvite: (args, cb) ->
      return cb new Reject 'NOUER' unless @session.isUser(id = args.id) and (username = args.username)
      name = args.name or ''

      async.waterfall [
        (next) =>
          @session.readUserPriv next

        (userPriv, next) =>
          unless userPriv.oauth # then require password
            return next new Reject "PASSWORD" unless (password = args.password) and password = utils.checksum password

            # set the password
            @_update 'users_priv', userPriv._id, null, [{'o': 1, 'k': 'password', 'v': password}], next
          else
            next()

        (next) =>
          # set the name, username, active
          @_update 'users', id, null, [{'o': 1, 'k': 'username', 'v': username},{'o':1,'k':'name','v':name},{'o':1,'k':'active','v': 1}], (err) =>
            return next new Reject 'USERNAME' if err?
            next()

      ], cb

    logInUsername: (username, password, cb) ->
      user = userPriv = null

      async.waterfall [
        (next) =>
          @_read 'users', null, null, {username}, (err, user_) =>
            if err? or !user_
              next new Reject 'USERNAME'
            else
              next err, user_

        (user_, next) =>
          user_ = user_[0] if Array.isArray user_
          console.log "SEE USER:",user_
          user = user_
          @_read 'users_priv', user._id, next

        (userPriv_, next) =>
          userPriv = userPriv_
          if !userPriv or userPriv.password isnt utils.checksum password
            return next new Reject 'PASSWORD'
          next()

      ], (err) => cb err, user, userPriv


    logInOAuth: (details, user, userPriv, cb) ->
      if (len = arguments.length) < 4
        cb = arguments[len-1]
        arguments[len-1] = null



    logIn: (details, cb) ->
      if username = details.username
        debug "Logging in via password: #{username}..."
        @logInUsername username, details.password, (err, user, userPriv) =>
          if err?
            if !userPriv or userPriv.oauth
              @logInOauth details, user, userPriv, (err) =>
                return cb err if err?
                @session.setUser user
                @session.sendUserDocs user, userPriv, => cb null, ''+user._id
            else
              cb err
          else
            @session.setUser user
            @session.sendUserDocs user, userPriv, => cb null, ''+user._id
      else
        @logInOauth details, (err, user, userPriv) =>
          return cb err if err?
          @session.setUser user
          @session.sendUserDocs user, userPriv, => cb null, ''+user._id

