#!/usr/bin/env coffee#--nodejs --debug-brk

connect = require 'connect'
express = require 'express'
Manifest = require 'manifest_mvc'
ace = require 'ace_mvc'
fs = require 'fs'
path = require 'path'
connectOauth = require 'connect_oauth'
manifestArgs = if 0 <= tmp = process.argv.indexOf('--manifest') then process.argv.splice(tmp).slice(1) else []
optimist = require 'optimist'
staticFiles = require './static_files'
nodemailer = require 'nodemailer'
require 'debug-fork'
debugEmail = global.debug 'email'

argv = optimist
  .default({
    p: 1337
    h: '127.0.0.1'
    l: ''
    P: 'https'
  })
  .alias('p','port')
  .alias('h','host')
  .alias('l','listen')
  .alias('P','protocol')
  .boolean('manifest')
  .describe('manifest', 'followed by a series of manifest options')
  .describe('listen', 'the IP address on which to listen')
  .argv

if argv.help
  optimist.showHelp()
  process.exit 0

readCertificateChain = ->
  dir = path.resolve(__dirname, '../resources/ssl_chain')
  fs.readFileSync(path.resolve(dir,file),encoding:'utf-8') for file in fs.readdirSync(dir).filter((name) -> /^\d+\.pem$/.test name).sort (a,b) ->
    a = parseInt(a,10)
    b = parseInt(b,10)
    return -1 if b < a
    return 1 if a < b
    0

key = fs.readFileSync path.resolve __dirname, '../resources/synopsi/ssl.key'
cert = fs.readFileSync path.resolve __dirname, '../resources/synopsi/ssl.crt'
ca = readCertificateChain()

app = express()
app.use express.compress()
if argv.protocol is 'https'
  server = require('https').createServer {key, cert, ca}, app
else
  server = require('http').createServer app

app.use connect.cookieParser()
app.use connect.multipart()
app.use express.cookieSession secret: 'EfrisjixTd/oDeR2reBJwm0tT67DDaVe9qW/JUYPOzjnY9502zXpQDzm'
connectOauth app,
  protocol: argv.protocol
  host: argv.host
  port: argv.port
  angellist:
    clientId: if argv.h is '127.0.0.1' then 'bbefb8072f1620524b6998ff2b49ce18' else '393af077648885dec9427e5497d145b8'
    clientSecret: if argv.h is '127.0.0.1' then '218e30a70233c2612a41c51b4b1a77b8' else 'f2dbc2cb26998a612e057f6a96695bab'

manifest = new Manifest '../mvc', manifestArgs

app.use staticFiles manifest.private.assetRoot, manifest.private.uploadsRoot

app.configure 'development', ->
  app.use connect.logger 'dev'

app.configure 'production', ->
  try
    fs.mkdirSync './logs'
  catch _error
  app.use connect.logger stream: fs.createWriteStream('./logs/access.log', flags: 'a')

debugger

favicon = fs.readFileSync path.resolve __dirname, '../public/img/favicon.ico'
app.get '/favicon.ico', (req,res,next) -> res.end favicon

app.use aceInst = ace server, manifest,
  # cookies:
  #   secure: (argv.protocol is 'https')
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
  mediatorGlobals:
    sendmail: (obj, cb) ->
      debugEmail "Sending email to [#{obj.to}]"
      obj.from = "Mike Robertson <mike@synop.si>"
      unless obj['text']?
        obj.generateTextFromHTML = true
      smtp.sendMail obj, (err) -> cb err

smtp = nodemailer.createTransport "SMTP",
  service: "Gmail"
  auth:
    user: "mike@synop.si"
    pass: "MGJ466a4*"

aceInst.on 'close', -> smtp.close()

if argv.listen
  server.listen port = argv.port, argv.listen, ->
    console.log "listening on #{argv.listen}:#{port}, pid #{process.pid}..."
else
  server.listen port = argv.port, ->
    console.log "listening on #{port}, pid #{process.pid}..."

