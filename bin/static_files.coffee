send = require 'send'
url = require 'url'
path = require 'path'
compressible = require 'compressible'
Negotiator = require 'negotiator'
_ = require 'lodash-fork'

regexStatic = /^\/+(static|uploads)\//
regexStaticToDir = /^\/+(?:static|uploads)\/+[^/]*\/+/

sendCompressedHeaders = (res, method) ->
  unless vary = res.getHeader("Vary")
    res.setHeader "Vary", "Accept-Encoding"
  else unless ~vary.indexOf("Accept-Encoding")
    res.setHeader "Vary", vary + ", Accept-Encoding"

  res.setHeader 'Content-Encoding', method
  return

module.exports = (staticRoot, uploadsRoot) ->
  (req, res, next) ->
    return next() unless cap = regexStatic.exec originalUrl = req.originalUrl
    pathname = url.parse(originalUrl).pathname.replace(regexStaticToDir,'')

    root = if cap[1] is 'static' then staticRoot else uploadsRoot

    error = ->
      res.statusCode = 404
      res.end ''
    
    done = ->
      send(req, pathname)
        .maxage(315360000000)
        .root(root)
        .on('error', error)
        .on('directory', error)
        .pipe(res)

    if (method = new Negotiator(req).preferredEncoding(['gzip','identity'])) is 'gzip'
      _.stat gzipPathname = pathname + ".gz", (err) ->
        unless err?
          sendCompressedHeaders res, method
          pathname = gzipPathname
        done()
    else
      done()
