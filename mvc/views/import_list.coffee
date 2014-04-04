_ = require 'lodash-fork'

module.exports =
  outlets: [
    'successes'
    'failures'
    'name'
  ]

  add: (name, succeeded, href) ->
    return if @ace.booting and @template.bootstrapped

    inner = _.unsafeHtmlEscape name

    if href?
      try
        href = encodeURI href
      catch
        href = ''

    inner = """<a href="#{href}">#{inner}</a>""" if href
    @$fileList.append """<li#{if succeeded? then " data-success=\"#{+!!succeeded}\""}>#{inner}</li>"""

    if succeeded? and !succeeded
      @failures.set @failures.get()||0 + 1
    else
      @successes.set @successes.get()||0 + 1
    return

  clear: ->
    @failures.set 0
    @successes.set 0
    @$fileList.html ''
    return

  outletMethods: [
    (failures, successes, name="item(s)") ->
      return if @ace.booting and @template.bootstrapped
      text = """#{successes||0} #{name}"""
      text += ", #{failures} error" if failures ||= 0
      @$fileCount.text text
      return

  ]

  constructor: ->
    if !@ace.onServer and @ace.booting and @template.bootstrapped
      successes = failures = 0

      for child in children = @$fileList.children().length
        if child.getAttribute and (success = child.getAttribute 'data-success')? and !success
          ++failures
        else
          ++succcesses

      @successes.set successes
      @failures.set failures
    return

