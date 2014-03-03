_ = require 'lodash-fork'

KEY_ENTER = 13
KEY_TAB = 9

module.exports = (config,arg1) ->
  if Array.isArray(arg1) or arg1.constructor is String
    options = 0
    fields = [].slice.call(arguments,1)
  else
    options = arg1
    fields = [].slice.call(arguments,2)

  for field in fields
    config["$#{field}"] ||= 'text'

  addField = (field) ->
    $field = @$[field]

    $field.on 'mousedown.editable', (event) =>
      shouldEdit = @depute 'shouldEdit', field
      if shouldEdit isnt undefined and !shouldEdit
        $field.removeAttr 'contenteditable'
      else
        $field.attr 'contenteditable', true
      return

    trigger = "keyup.editable#{if options.withInput then " input.editable" else ""}"

    if t = options.throttle
      setValue = _.throttle (=> @[field].set @domCache["$#{field}"]), (if typeof t is 'number' then t else 200)
      $field.on trigger, =>
        @domCache["$#{field}"] = $field.text()
        setValue()
    else
      $field.on trigger, => @[field].set @domCache["$#{field}"] = $field.text()

    $field.on 'keydown.editable', (event) =>
      switch event.keyCode
        when KEY_ENTER
          start = $.selection()?.start
          $.selection.delete()
          if start
            # this fixes a presentation bug with trailing newlines in (all?) browsers
            if $field.isLastChar start
              end = $.addText(start, '\n\n', true).end
              --end.offset
            else
              end = $.addText(start, '\n', true).end
            $.selection end
          event.preventDefault()
          return false
        when KEY_TAB
          start = $.selection()?.start
          $.selection.delete()
          $.selection $.addText(start, '\t', true).end if start
          event.preventDefault()
          return false


  config.constructor.unshift ->
    addField.call this, field for field in fields
