_ = require 'lodash-fork'
defaultImgPrinter = require 'marked-fork/lib/img_printer'

module.exports = (config) ->
  config.uploadImage = (id, b64, extension) ->
    return unless mime = _.imgMime extension

    @imgUploads[id] = {mime, b64}

    session = @session.get()

    # TODO error handling
    session.imgExists id, extension, (err, exists) ->
      if err?
        return
      if !exists
        session.imgUpload id, extension, b64, (err) ->

    return

  config.imgPrinter = (href, title, node) ->
    if img = @imgUploads[id = href.replace(/\..*$/, '')]
      href = _.dataUri.format img.mime, img.b64
      defaultImgPrinter href, title, node

  config.constructor.unshift ->
    @imgUploads = {}
    return
