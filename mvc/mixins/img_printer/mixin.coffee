defaultImgPrinter = require 'marked-fork/lib/img_printer'
regexRelUrl = /^(?:[^/]|\/[^/])/
_ = require 'lodash-fork'

module.exports = (config) ->

  config.imgPrinter = (href, title, node, inLink) ->
    return deputed if deputed = @depute('imgPrinter', href, title, node, inLink)

    uploadsServerRoot = @ace.manifest.uploadsServerRoot
    if regexRelUrl.test href
      href = href.replace(/^\/+/,'')
      # TODO asset versioning...
      href = uploadsServerRoot + "/1/" + href
    img = defaultImgPrinter href, title, node, inLink
    """<a target="_blank" href="#{_.unsafeHtmlEscape href}">#{img}</a>"""

  config.constructor.unshift ->
    orig = @imgPrinter
    @imgPrinter = => orig.apply this, arguments
    return
  
