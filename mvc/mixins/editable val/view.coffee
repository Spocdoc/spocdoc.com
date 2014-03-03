module.exports = (config, fields...) ->
  for field in fields
    config["$#{field}"] ||= 'val'

  addField = (field) ->
    $field = @$[field]
    $field.on 'keyup.editable input.editable', (event) =>
      @[field].set @domCache["$#{field}"] = $field.val()

  config.constructor.unshift ->
    addField.call this, field for field in fields
