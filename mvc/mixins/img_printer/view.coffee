defaultImgPrinter = require 'marked-fork/lib/img_printer'
regexRelUrl = /^(?:[^/]|\/[^/])/

module.exports = (config) ->

  config.imgPrinter = (href, title, node) ->
    return deputed if deputed = @depute('imgPrinter', href, title, node)

    uploadsServerRoot = @ace.manifest.uploadsServerRoot
    if regexRelUrl.test href
      href = href.replace(/^\/+/,'')
      # TODO asset versioning...
      href = uploadsServerRoot + "/1/" + href
    defaultImgPrinter href, title, node

  config.constructor.unshift ->
    orig = @imgPrinter
    @imgPrinter = => orig.apply this, arguments
    return
  
