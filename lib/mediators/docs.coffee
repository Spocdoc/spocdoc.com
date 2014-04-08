ObjectID = require('mongo-fork').ObjectID
Reject = require 'ace_mvc/lib/error/reject'
debug = global.debug 'app:mediators:docs'
debugError = global.debug 'error'
utils = require '../utils'
path = require 'path'
_ = require 'lodash-fork'
async = require 'async'
markedInline = require 'marked-fork/lib/inline'
fs = require 'fs'

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

    run: (id, version, cmd, args, cb) ->
      switch cmd
        when 'import' then @import args.src, args.name, args.options, cb
        else super
      return


# ===========================================

    parseImages: (html, cb) ->
      out = ''
      src = html.src
      start = 0

      images = []

      html.visit (node, visitor) =>
        if node.type is 'link' and node['img']
          pre = node.pre || 0

          startOffset = visitor.offset() - pre
          endOffset = visitor.offset(node.src.length - pre)

          href = node.href
          if (data = _.dataUri.parse href) and (id = utils.imgId(data['b64'])) and (extension = _.imgExtension(data['mime']))
            try
              imgSrc = new Buffer data['b64'], 'base64'
              href = "#{id}.#{extension}"
              images.push
                name: href
                src: imgSrc
            catch _error
              href = 'missing.png'
          else
            href = "missing.png"

          if cap = markedInline.link.exec node.src
            if title = node.title
              title = _.quote title
            else
              title = ''
            newSrc = """![#{cap[1]}](#{href}#{title})"""
          else # ?!
            return

          out += src.substring(start, startOffset) + newSrc
          start = endOffset
          return

        return

      out += src.substr(start)

      uploadsRoot = @manifest.private.uploadsRoot

      uploadImage = (obj, next) =>
        {src,name} = obj
        filePath = path.resolve uploadsRoot, name
        fs.writeFile filePath, src, next

      if images.length
        _.mkdirp uploadsRoot, =>
          async.each images, uploadImage, (err) =>
            if err?
              debugError "Error with image upload: ",err
            cb null, out
      else
        cb null, out


    import: (b64, name, options, cb) ->
      return cb new Reject 'NOUSER' unless userId = @session.userId

      try
        buffer = new Buffer b64, "base64"
      catch _error
        return cb new Reject "BAD64"

      src = ''
      doc = html = null

      async.waterfall [
        (next) =>
          _.fileType buffer, next

        (type, next) =>
          unless type is 'txt'
            return next new Reject 'BADFILE'

          try
            src = buffer.toString 'utf-8'
          catch _error
            return next new Reject 'BAD64'

          meta = {}

          if options.nameIsTitle
            meta['title'] = title if title = path.basename name, path.extname name

          html = utils.makeHtml src, userId, meta
          _.extend doc = utils.makeDoc(html, userId, meta),
            _id: docId = new ObjectID()
            _v: 1

          @parseImages html, next

        (src, next) =>
          doc['text'] = src

          @_create 'docs', doc, (err) =>
            # TODO return some way of linking to the new doc
            next err, name
      ], (err) =>
        if err?
          debugError "ERROR importing: ",err
        cb.apply null, arguments


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


