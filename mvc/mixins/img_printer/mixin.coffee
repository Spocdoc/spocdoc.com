defaultImgPrinter = require 'marked-fork/lib/img_printer'
regexRelUrl = /^(?:[^/]|\/[^/])/
utils = require '../../../lib/utils'
_ = require 'lodash-fork'

module.exports = (config) ->

  config.imgPrinter = (href, title, node, inLink) ->
    return deputed if deputed = @depute('imgPrinter', href, title, node, inLink)

    uploadsServerRoot = @ace.manifest.uploadsServerRoot
    if local = utils.localUrl href
      # TODO asset versioning...
      href = uploadsServerRoot + "/1" + local
    img = defaultImgPrinter href, title, node, inLink
    if inLink
      img
    else
      """<a target="_blank" href="#{_.unsafeHtmlEscape href}">#{img}</a>"""

  config.constructor.unshift ->
    orig = @imgPrinter
    @imgPrinter = => orig.apply this, arguments
    return
  
