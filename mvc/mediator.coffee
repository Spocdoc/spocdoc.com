fs = require 'fs'
path = require 'path'
OJSON = require 'ojson'
callback = require 'ace_mvc/lib/db/callback'

handlerFns = {}
for file in fs.readdirSync mediators = path.resolve __dirname, '../lib/mediators'
  handlerFns[path.basename file, path.extname file] = require "#{mediators}/#{file}"

defaultReject = (clazz, method) ->
  clazz.prototype[method] = (coll, args...) ->
    return handler[method](args...) if (handler = @handlers[coll])?.constructor.prototype.hasOwnProperty(method)
    args[args.length-1].reject 'unhandled'

proxySuper = (proto, baseMethod, method) ->
  proto[method] = ->
    (args = Array.apply(null,arguments)).unshift @coll
    baseMethod.apply this, args

module.exports = (MediatorBase) ->

  class Handler extends MediatorBase
    constructor: (db, sock, @coll, @session, @handlers) -> super

    for method in ['create','read','update','delete','run','distinct']
      proxySuper @prototype, MediatorBase.prototype[method], method

  handlerClasses = {}
  handlerClasses[coll] = fn(Handler) for coll, fn of handlerFns

  class Mediator extends MediatorBase

    constructor: ->
      super

      @session = {}
      @handlers = {}
      @handlers[coll] = new clazz @db, @sock, coll, @session, @handlers for coll, clazz of handlerClasses

    cookies: (cookies, cb) ->
      reply = {}
      wait = 1
      done = -> cb.ok reply

      for coll, handler of @handlers when handler.cookies
        ++wait
        do (coll) =>
          handler.cookies cookies, new callback.Cookies =>
            reply[coll] = OJSON.toOJSON Array.apply null, arguments if arguments.length
            done() unless --wait
      done() unless --wait

      return

    defaultReject this, method for method in ['create','read','update','delete','run','distinct']

