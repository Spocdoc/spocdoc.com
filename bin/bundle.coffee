#!/usr/bin/env coffee
#--nodejs --debug-brk

Manifest = require 'manifest_mvc'
manifestArgs = if 0 <= tmp = process.argv.indexOf('--manifest') then process.argv.splice(tmp).slice(1) else []
optimist = require 'optimist'

debugger

manifest = new Manifest '../mvc', manifestArgs
manifest.update (err) ->
  return console.error err if err?
  console.log "success"

