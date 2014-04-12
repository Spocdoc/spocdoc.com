ObjectID = require('mongo-fork').ObjectID
Reject = require 'ace_mvc/lib/error/reject'
Html = require 'marked-fork/html'
debug = global.debug 'app:mediators:docs'
debugError = global.debug 'error'
utils = require '../utils'
path = require 'path'
_ = require 'lodash-fork'
async = require 'async'
markedInline = require 'marked-fork/lib/inline'
fs = require 'fs'
css = require 'css'
stylus = require 'stylus'
nib = require 'nib'

getCode = (html) ->
  code = ''

  html.visit (node, visitor) =>
    if node.type is 'code'
      code += node.spec.blockText
    return

  code

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
        when 'getCss' then @getCss id, args.id, cb
        else super
      return


# ===========================================

    getCss: (id, elemId, cb) ->
      async.waterfall [
        (next) =>
          @_read 'docs', id, next

        (doc, next) =>
          return next new Reject "NODOC" unless doc
          try
            html = new Html doc.text
            format = html.meta.code or 'css'

            switch format
              when 'css'
                next null, getCode(html)
              when 'stylus'
                stylus(getCode(html))
                  .use(nib()).import('nib')
                  .render next
              else
                next new Reject 'BADFORMAT'

          catch _error
            return next _error

        (code, next) =>
          try
            obj = css.parse code
            for rule in obj.stylesheet.rules
              rule.selectors = ("##{elemId} " + s for s in rule.selectors)
            code = css.stringify obj
            next null, code
          catch _error
            return next _error

      ], (err, code) =>
        if err?
          debugError "Error getting css: ",err
        cb err, code

    parseImages: (html, cb) ->
      out = ''
      src = html.src
      start = 0

      images = []

      getHref = (data) ->
        try
          if (id = utils.imgId(data['b64'])) and (extension = _.imgExtension(data['mime']))
            imgSrc = new Buffer data['b64'], 'base64'
            href = "#{id}.#{extension}"
            images.push
              name: href
              src: imgSrc
        catch _error
        href or "missing.png"

      html.visit (node, visitor) =>
        if (node.type is 'link' and node['img']) or def = node.type is 'def'
          pre = node.pre || 0

          startOffset = visitor.offset() - pre
          endOffset = visitor.offset(node.src.length - pre)

          return unless data = _.dataUri.parse(if def then node.spec.href else node.href)
          href = getHref(data)

          if def
            leadingSpace = /^\s*/.exec(node.src)[0]
            trailingSpace = /\s*$/.exec(node.src)[0]
            if title = node.spec.title or ''
              title = " (#{title})"
            newSrc = """#{leadingSpace}[#{node.spec.name}]: #{href}#{title}#{trailingSpace}"""
          else
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

    importSrc: (src, editors, meta, cb) ->
      doc = null
      html = null

      async.waterfall [
        (next) =>
          try
            html = utils.makeHtml src, editors, meta
            _.extend doc = utils.makeDoc(html, editors, meta),
              _id: docId = new ObjectID()
              _v: 1
            @parseImages html, next
          catch _error
            next _error

        (src, next) =>
          doc['text'] = src

          @_create 'docs', doc, next
      ], cb

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
          _.isText buffer, next

        (isText, next) =>
          unless isText
            return next new Reject 'BADFILE'

          try
            src = buffer.toString 'utf-8'
          catch _error
            return next new Reject 'BAD64'

          meta = {}

          if options.nameIsTitle
            meta['title'] = title if title = path.basename name, path.extname name

          @importSrc src, userId, meta, next
      ], (err) =>
        if err?
          debugError "ERROR importing: ",err
        cb err, name


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


