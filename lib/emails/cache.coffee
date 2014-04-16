path = require 'path'
async = require 'async'
fs = require 'fs'
jade = require 'jade'
stylus = require 'stylus'
nib = require 'nib'
ejs = require 'ejs'
ejs.open = '{{'
ejs.close = '}}'

cache = {}

module.exports = (filePath, cb) ->
  return cb null, c.htmlFn, c.textFn, c.css if c = cache[filePath]

  jadePath = filePath.replace(/\.[^.]*$/,'.jade')
  ejsPath = filePath.replace(/\.[^.]*$/,'.ejs')
  stylPath = filePath.replace(/\.[^.]*$/,'.styl')

  async.parallel
    htmlFn: (done) ->
      async.waterfall [
        (next) =>
          fs.readFile jadePath, encoding: 'utf-8', next

        (content, next) =>
          next null, jade.compile(content, filename: jadePath)
      ], done

    textFn: (done) ->
      async.waterfall [
        (next) =>
          fs.exists ejsPath, (exists) =>
            if exists
              fs.readFile ejsPath, encoding: 'utf-8', next
            else
              done null, null

        (content, next) =>
          next null,  ejs.compile(content, filename: ejsPath)

      ], done

    css: (done) ->
      async.waterfall [
        (next) =>
          fs.exists stylPath, (exists) =>
            if exists
              fs.readFile stylPath, encoding: 'utf-8', next
            else
              done null, ''

        (content, next) =>
          stylus(content)
            .set('filename', stylPath)
            .use(nib()).import('nib')
            .render next

      ], done
    (err, obj) ->
      return cb err if err?

      cache[filePath] = obj
      cb null, obj.htmlFn, obj.textFn, obj.css

