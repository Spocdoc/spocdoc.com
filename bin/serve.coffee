#!/usr/bin/env coffee
#--nodejs --debug-brk

connect = require 'connect'
express = require 'express'
Manifest = require 'manifest_mvc'
ace = require 'ace_mvc'
fs = require 'fs'
path = require 'path'
connectOauth = require 'connect_oauth'
manifestArgs = if 0 <= tmp = process.argv.indexOf('--manifest') then process.argv.splice(tmp).slice(1) else []
optimist = require 'optimist'

sessionSecret = 'EfrisjixTd/oDeR2reBJwm0tT67DDaVe9qW/JUYPOzjnY9502zXpQDzm'

argv = optimist
  .default({
    p: 1337
    h: '127.0.0.1'
    P: 'https'
  })
  .alias('p','port')
  .alias('h','host')
  .alias('P','protocol')
  .boolean('manifest')
  .describe('manifest', 'followed by a series of manifest options')
  .argv

if argv.help
  optimist.showHelp()
  process.exit 0

key = fs.readFileSync path.resolve __dirname, '../resources/ssl.key'
cert = fs.readFileSync path.resolve __dirname, '../resources/ssl.crt'

app = express()
app.use express.compress()
if argv.protocol is 'https'
  server = require('https').createServer {key, cert}, app
else
  server = require('http').createServer app

app.use connect.cookieParser()
app.use connect.multipart()
app.use express.session secret: sessionSecret
connectOauth app,
  protocol: argv.protocol
  host: argv.host
  port: argv.port

app.configure 'development', ->
  app.use connect.logger 'dev'

app.configure 'production', ->
  try
    fs.mkdirSync './logs'
  catch _error
  app.use connect.logger stream: fs.createWriteStream('./logs/access.log', flags: 'a')

debugger

manifest = new Manifest '../mvc', manifestArgs

app.use ace server, manifest,
  # cookies:
    # domain: '192.168.1.107'
    # secure: false
  mongodb:
    host: '/tmp/mongodb-27017.sock'
    # host: 'ip-10-73-182-71.ec2.internal'
    # port: 27017
    db: 'test'
  redis:
    host: '/var/run/redis/redis.sock'
    port: 6379
    options:
      retry_max_delay: 30*1000

server.listen port = argv.port, ->
  console.log "listening on #{port}, pid #{process.pid}..."

