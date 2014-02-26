#!/usr/bin/env coffee
#--nodejs --debug-brk

connect = require 'connect'
express = require 'express'
optimist = require 'optimist'
Manifest = require 'manifest_mvc'
ace = require 'ace_mvc'
fs = require 'fs'

argv = optimist
  .default({
    p: 1337
  })
  .alias('p','port')
  .argv

if argv.help
  optimist.showHelp()
  process.exit 0

app = express()
app.use express.compress()
server = require('http').createServer(app)

app.use connect.cookieParser()
app.use connect.multipart()

app.configure 'development', ->
  app.use connect.logger 'dev'

app.configure 'production', ->
  try
    fs.mkdirSync './logs'
  catch _error
  app.use connect.logger stream: fs.createWriteStream('./logs/access.log', flags: 'a')

debugger

manifest = new Manifest '../mvc'

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

