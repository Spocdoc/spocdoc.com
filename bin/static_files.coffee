send = require 'send'
url = require 'url'
path = require 'path'
compressible = require 'compressible'

regexStatic = /^\/+static\//
regexStaticToDir = /^\/+static\/+[^/]*\/+/



module.exports = (root) ->
  (req, res, next) ->
    return next() unless regexStatic.test originalUrl = req.originalUrl
    pathname = url.parse(originalUrl).pathname.replace(regexStaticToDir,'')

    error = ->
      res.statusCode = 404
      res.end ''

    send(req, pathname)
      .maxage(315360000)
      .root(root)
      .on('error', error)
      .on('directory', error)
      .pipe(res)

