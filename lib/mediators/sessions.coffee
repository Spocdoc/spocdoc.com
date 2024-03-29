utils = require '../utils'
diff = require "diff-fork"
mongodb = require 'mongo-fork'
DBRef = mongodb.DBRef
ObjectID = mongodb.ObjectID
Reject = require 'ace_mvc/lib/error/reject'
Uri = require 'uri-fork'
async = require 'async'
OJSON = require 'ojson'
oauth = require '../oauth'
Evernote = require 'evernote-fork'
_ = require 'lodash-fork'
path = require 'path'
regexId = /^[0-9a-f]{24}$/
regexExtension = /^[a-zA-Z]+$/
fs = require 'fs'
constants = require '../../mvc/constants'
inviteEmail = require '../emails/invite'

debug = global.debug "ace:app:sessions"
debugError = global.debug "error"

module.exports = (Base) ->
  class Handler extends Base
    cookies: (cookies, cb) ->
      return cb() unless (cookie = cookies.session) and utils.validateCookie cookie

      @session.set sessId = cookie[0]
      debug "setting session to #{sessId}"

      async.waterfall [
        (next) => @_read 'sessions', sessId, next

        (session, next) =>
          if user = session.user
            @session.setUser user, (err, user, userPriv) => next null
          else
            @session.userId = null
            next()
      ], cb

    create: (doc, cb) ->
      if doc.cookie or ((user = doc.user) and !@session.isUser user)
        return cb new Reject "INVALID"

      @_create 'sessions', doc, (err) =>
        return cb err if err?

        @session.set sessId = ''+doc._id
        @session.userId = ''+(if user then user._id or user.oid or user else '')

        cookie = utils.makeCookie sessId
        ops = diff doc, cookie, path: ['cookie']

        @_update 'sessions', sessId, doc._v, ops, (err) =>
          return cb err if err?
          cb null, doc._v, ops

    update: (id, version, ops, cb) ->
      return cb new Reject "NOSESSION" unless @session.isAnySession id
      super id, version, ops, cb, (from, ops, to, next) =>
        if to.user and @session.toId(to.user) isnt @session.toId(from.user)
          next new Reject "NOUSER"
        else
          next()

    # can only read previous or current session
    read: (id, version, query, limit, sort, cb) ->
      return cb new Reject 'NOQUERY' unless id

      if Array.isArray id
        super id, version, query, limit, sort, cb, (query, next) =>
          arr = []; i = 0
          arr[i++] = id for id in query._id.$in when @session.isAnySession id
          query._id.$in = arr
          next null, query
      else
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
        when 'oauthService' then @oauthService args.details, args.fn, args.args, cb
        when 'imgExists' then @imgExists args.id, args.extension, cb
        when 'imgUpload' then @imgUpload args.id, args.extension, args.b64, cb
        when 'admin' then @admin args, cb
        else super
      return

# -------------------------------------------------

    pendingUsers: (cb) ->
      privs = users = null
      numActiveUsers = null

      async.waterfall [
        (next) =>
          @db.run 'count', 'users', {active: 1}, next

        (count, next) =>
          numActiveUsers = count

          @db.run 'find', 'users', {active: 0}, {name: 1}, next

        (users_, next) =>
          users = users_

          return cb null, [] unless users and Array.isArray(users) and users[0]

          ids = []
          ids.push doc._id for doc in users

          # get the email addresses for these users...
          @db.run 'find', 'users_priv', {_id: {$in: ids}}, {email: 1, invited: 1}, next

        (privs_, next) =>
          return cb null, [] unless privs_ and Array.isArray(privs_) and privs_[0]

          privs = {}
          privs[priv._id] = priv for priv in privs_

          pendingUsers = []; i = -1
          for user in users when (priv = privs[user._id]) and email = priv.email
            pendingUsers[++i] = {
              id: ''+user._id
              name: user.name
              email: email
              invited: priv.invited or null
            }

          next null, {pendingUsers, numActiveUsers}

      ], cb

    sendInvite: (userId, cb) ->
      user = priv = null

      async.waterfall [
        (next) =>
          @_read 'users', userId, next

        (user_, next) =>
          user = user_
          @_read 'users_priv', userId, next

        (priv_, next) =>
          priv = priv_

          return cb new Reject 'NOUSER', "can't find user" unless priv and user
          return cb new Reject 'NOEMAIL', "no email listed" unless email = priv.email

          inviteEmail user, priv, next

        (obj, next) =>
          @sendmail obj, next

        (next) =>
          @_updateClient 'users_priv', userId, null, [{'o': 1, 'k': 'invited', 'v': new Date()}], next

      ], cb


    admin: (args, cb) ->
      return cb new Reject 'NOADMIN' unless @session.isUser constants['synopsiUser']
      {cmd, args} = args

      switch cmd
        when 'pendingUsers'
          @pendingUsers cb
        when 'invite'
          @sendInvite.apply this, (args or []).concat cb
        else
          return cb new Reject 'BADCMD'

    imgExists: (id, extension, cb) ->
      return cb new Reject "BADID" unless regexId.test(id=''+id) and regexExtension.test extension=''+extension
      filePath = path.resolve @manifest.private.uploadsRoot, "#{id}.#{extension}"
      fs.exists filePath, (exists) => cb null, !!exists

    imgUpload: (id, extension, b64, cb) ->
      return cb new Reject 'NOUSER' unless userId = @session.userId
      return cb new Reject "BADID" unless regexId.test(id=''+id) and regexExtension.test extension=''+extension
      dir = @manifest.private.uploadsRoot

      async.waterfall [
        (next) => _.mkdirp dir, next
        (dir_, next) =>
          try
            filePath = path.resolve dir, "#{id}.#{extension}"
            buffer = new Buffer b64, "base64"
            fs.writeFile filePath, buffer, next
          catch _error
            next new Reject "BADB64"
      ], cb

    oauthService: (details, fn, args, cb) ->
      unless details?.provider is 'evernote'
        return cb new Reject 'NOSERVICE'
      return cb new Reject 'NOUSER' unless userId = @session.userId

      evernote = new Evernote details

      switch fn
        when 'listNotebooks'
          evernote.notebooks (err, list) =>
            return cb err if err?
            notebooks = []

            for notebook,i in list
              notebooks[i] = {
                name: notebook.name
                guid: notebook.guid
              }

            cb null, notebooks

        when 'listNotes'
          [guid] = args
          evernote.notes guid, (err, list) =>
            return cb err if err?
            notes = []

            for note, i in list
              notes[i] = {
                title: note.title
                guid: note.guid
              }

            cb null, notes

        when 'importNote'
          [guid] = args

          async.waterfall [
            (next) => evernote.md guid, tags: true, images: true, next
            (src, note, next) =>
              return cb err if err?

              meta =
                title: note.title
                date: new Date note.created
                tags: note.tags

              @handlers['docs'].importSrc src, userId, meta, next
          ], cb

        else
          return cb new Reject 'UNKNOWN'

      return


    readOrCreate: (id, version, cb) ->
      debug "readOrCreate with id [",id,"] version [",version,"]"

      doc =
        _id: new ObjectID(''+id)
        _v: version + 1
        cookie: utils.makeCookie id

      @_create 'sessions', doc, (err) =>
        if err?
          return cb err unless @session.isAnySession id
          @_read 'sessions', id, version, cb
        else
          cb null, doc

    invite: (details, cb) ->
      user = userPriv = id = undefined
      inviteNow = false
      numActiveUsers = 0
      maxActiveUsers = Infinity

      async.waterfall [
        # get the number of active users and the max. invite immediately if below the max
        (next) =>
          @db.run 'count', 'users', {active: 1}, next

        (count, next) =>
          numActiveUsers = count
          @db.run 'findOne', 'users_priv', {_id: new ObjectID(constants['synopsiUser'])}, {maxActiveUsers: 1}, next

        (synopsiUser, next) =>
          maxActiveUsers = +max if max = synopsiUser?.maxActiveUsers

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
            picture: details.picture or null
            active: 0
            name: details.name or null

          userPriv =
            _id: id
            _v: 1
            email: details.email &&= (''+details.email).toLowerCase()
            created: new Date()
            invite: utils.randomPassword()
            oauthId: id

          if details.username
            userPriv.prefUsername = (''+details.username).toLowerCase()
          else if (email = details.email) and utils.validUsername prefUsername = email.replace /@.*$/,''
            userPriv.prefUsername = prefUsername

          if details.provider
            userPriv.oauthProvider = details.provider
            userPriv.oauthId = details.id
            userPriv.oauthTokens =
              access: details.access
              secret: details.secret
              refresh: details.refresh

            if inviteNow = (details.provider is 'angellist' or numActiveUsers < maxActiveUsers)
              userPriv.invited = new Date()

          @session.read next

        (session, next) =>
          userPriv.lastDoc = lastDoc if lastDoc = session.lastDoc
          @_create 'users', user, next

        (next) =>
          @_create 'users_priv', userPriv, (err) =>
            if err?
              @_delete 'users', id, ->

              err ||= ''

              if /\bduplicate key\b/.test(err) and /\busers_priv.\$email\b/.test(err)
                # duplicate email -- means the user exists already. not an error

                prevInviteNow = inviteNow
                inviteNow = false
                currentUserPriv = currentUser = null
                done = next

                async.waterfall [
                  (next) =>
                    @db.run 'findOne', 'users_priv', {email: userPriv.email}, next
                  (currentUserPriv_, next) =>
                    return next 1 unless currentUserPriv = currentUserPriv_
                    @_read 'users', currentUserPriv._id, next
                  (currentUser_, next) =>
                    return next 1 unless currentUser = currentUser_
                    return next 1 unless currentUser.active or currentUserPriv.invited

                    useOauth = currentUserPriv.oauthProvider

                    if details.provider
                      # try logging in with the oauth credentials that were sent
                      @logInOAuth details, currentUser, currentUserPriv, null, (err) =>
                        if err? # can't log in with this ID
                          unless err instanceof Reject and err.code is 'INVITED'
                            return done new Reject 'LOGIN', {useOauth, email: currentUserPriv.email}
                        inviteNow = true
                        userPriv = currentUserPriv
                        user = currentUser
                        next null
                    else
                      # immediately send a LOGIN reject telling them to just log in (user/pass or another oauth)
                      done new Reject "LOGIN", {useOauth}

                ], (err) => done()
              else
                next err
            else
              next()
      ], (err) =>
        return cb err if err?

        if inviteNow and userPriv
          return cb null, (''+userPriv._id), userPriv.invite

        cb null


    validateInvite: (id, token, cb) ->
      userPriv = null
      async.waterfall [
        (next) =>
          @_read 'users_priv', id, next

        (userPriv_, next) =>
          return next new Reject "INVALID" unless (userPriv = userPriv_) and userPriv.invite is token
          @session.setUser userPriv, next

        (next) =>
          if docId = userPriv.introDoc
            docId = ''+docId
          next null, docId

      ], cb

    acceptInvite: (args, cb) ->
      return cb new Reject 'NOUSER' unless @session.isUser(id = args.id)
      name = ''+(args.name or '')
      username = ''+(args.username or '').toLowerCase()

      unless utils.validUsername username
        return cb new Reject 'USERNAME'

      introDocId = null
      userPriv = null

      async.waterfall [
        (next) =>
          @session.readUser next

        (user, next) =>
          return next new Reject 'NOUSER' unless user
          return cb() if user.active

          @session.readUserPriv next

        (userPriv_, next) =>
          return next new Reject 'NOUSER' unless userPriv = userPriv_

          unless userPriv.oauthProvider # then require password
            return next new Reject "PASSWORD" unless (password = args.password) and utils.validPassword(password) and password = utils.checksum password

            # set the password
            @_updateClient 'users_priv', userPriv._id, null, [{'o': 1, 'k': 'password', 'v': password}], next
          else
            next()

        (next) =>
          # set the name, username, active
          @_updateClient 'users', id, null, [{'o': 1, 'k': 'username', 'v': username},{'o':1,'k':'name','v':name},{'o':1,'k':'active','v': 1}], (err) =>
            return next new Reject 'USERNAME' if err?
            next()

        (next) =>
          # add the introduction doc
          @_read 'docs', constants['docIntro'], next

        (doc, next) =>
          next() unless doc # silent error -- doc should exist
          doc = utils.makeFork doc, id

          @_create 'docs', doc, (err) =>
            return next err if err?
            @clientCreate 'docs', doc
            introDocId = doc._id
            next()

        (next) =>
          @_updateClient 'users_priv', userPriv._id, null, [{'o': 1, 'k': 'introDoc', 'v': introDocId}], next

        (next) =>
          next null, (''+introDocId)

      ], cb

    logInEmail: (email, password, cb) ->
      user = userPriv = null
      email = (''+email).toLowerCase()

      async.waterfall [
        (next) =>
          @_read 'users_priv', null, null, {email}, (err, userPriv_) =>
            if err? or !userPriv_
              next new Reject 'EMAIL'
            else
              next err, userPriv_

        (userPriv_, next) =>
          userPriv_ = userPriv_[0] if Array.isArray userPriv_
          userPriv = userPriv_

          # first verify the account has been activated
          @_read 'users', userPriv._id, next

        (user_, next) =>
          unless user = user_
            return next new Reject 'NOUSER'

          unless user.active
            return next new Reject 'INVITED', [(''+userPriv._id), userPriv.invite] if userPriv.invited

            return next new Reject 'NOTACTIVE'

          if !userPriv or (userPriv.password isnt utils.checksum password)
            return next new Reject 'PASSWORD'

          next()

      ], (err) => cb err, null, userPriv


    logInUsername: (username, password, cb) ->
      user = userPriv = null
      username = (''+username).toLowerCase()

      async.waterfall [
        (next) =>
          @_read 'users', null, null, {username}, (err, user_) =>
            if err? or !user_
              next new Reject 'USERNAME'
            else
              next err, user_

        (user_, next) =>
          user_ = user_[0] if Array.isArray user_
          user = user_

          @_read 'users_priv', user._id, next

        (userPriv_, next) =>
          userPriv = userPriv_

          unless user.active
            return next new Reject 'INVITED', [(''+userPriv._id), userPriv.invite] if userPriv.invited
            return next new Reject 'NOTACTIVE'

          if !userPriv or userPriv.password isnt utils.checksum password
            return next new Reject 'PASSWORD'
          next()

      ], (err) => cb err, user, userPriv


    logInOAuth: (details, user, userPriv, err, cb) ->
      if (len = arguments.length) < 4
        cb = arguments[len-1]
        arguments[len-1] = null

      unless (oauthProvider = details.provider) and (oauthId = details.id)
        # missing oauth details. they may have tried logging in with user/pass when setup with oauth...
        return async.waterfall [
          (next) =>
            if userPriv
              next null, userPriv
            else if user
              @_read 'users_priv', user._id, next
            else
              return next null, null

          (userPriv_, next) =>
            unless userPriv = userPriv_
              return next err or new Reject 'NOUSER'

            if provider = userPriv.oauthProvider
              return next new Reject('USEOAUTH',provider)

            next new Reject 'OAUTH'

        ], (err) => cb err, user, userPriv

      user = userPriv = null

      async.waterfall [
        (next) =>
          return next null, userPriv if userPriv
          @_read 'users_priv', null, null, {oauthProvider, oauthId}, next
        (userPriv_, next) =>
          unless (userPriv = if Array.isArray(userPriv_) then userPriv_[0] else userPriv_)
            return next err or new Reject 'NOTFOUND'
          oauth.verifyId details, next
        (next) =>
          return next null, user if user
          @_read 'users', userPriv._id, null, next
        (user_, next) =>
          unless user = user_
            return next err or new Reject 'NOUSER'
          unless user.active
            return next new Reject 'INVITED', [(''+userPriv._id), userPriv.invite] if userPriv.invited
            return next new Reject 'NOTACTIVE'
          next()
      ], (err) => cb err, user, userPriv

    logIn: (details, cb) ->
      async.waterfall [
        (next) =>
          if (username = details.username) and (!details.provider or details.password)
            fn = if ~username.indexOf('@') then @logInEmail else @logInUsername
            debug "Logging in username/email: #{username}..."
            fn.call this, username, details.password, (err, user, userPriv) =>
              if err? and (!userPriv or userPriv.oauthProvider)
                return @logInOAuth details, user, userPriv, err, next
              next err, user, userPriv
          else
            @logInOAuth details, next
        (user, userPriv, next) =>
          @session.setUser user, userPriv, (err, user, userPriv) => next err
        ], (err) =>
          return cb err if err?
          cb null, @session.userId

