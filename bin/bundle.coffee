#!/usr/bin/env coffee#--nodejs --debug-brk

Manifest = require 'manifest_mvc'

debugger

manifest = new Manifest '../mvc'
manifest.update (err) ->
  return console.error err if err?
  console.log "success"

