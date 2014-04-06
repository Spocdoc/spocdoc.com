defaultImgPrinter = require 'marked-fork/lib/img_printer'
regexRelUrl = /^(?:[^/]|\/[^/])/

module.exports = (config) ->

  config.imgPrinter = (href, node) ->
    return deputed if deputed = @depute('imgPrinter', href, node)

    assetServerRoot = @ace.manifest.assetServerRoot
    if regexRelUrl.test href
      href = href.replace(/^\/+/,'')
      # TODO asset versioning...
      href = assetServerRoot + "/1/uploads/" + href
    defaultImgPrinter href, node

  config.constructor.unshift ->
    orig = @imgPrinter
    @imgPrinter = => orig.apply this, arguments
    return
  
