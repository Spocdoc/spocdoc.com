KEY_ENTER = 13

module.exports = (config, fields...) ->
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
    $field.on 'input.editable keyup.editable', (event) =>
      @[field].set @domCache["$#{field}"] = $field.text()
    $field.on 'keydown.editable', (event) =>
      if event.keyCode is KEY_ENTER
        event.preventDefault()
        return false

  config.constructor.unshift ->
    addField.call this, field for field in fields
