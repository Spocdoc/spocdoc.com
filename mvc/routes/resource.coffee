_ = require 'lodash-fork'
regexSpace = new RegExp _.regexp_s, 'g'

toSlug = (name) ->
  return name unless name = name?.get()
  name.replace regexSpace, '-'

module.exports = (modelPath, coll, slug) ->
  model = @var modelPath
  @[slug].set -> toSlug model.get slug
  @id.set -> model.get()?.id

  @id.addOutflow =>
    if (id = @id.value)
      if id isnt model.value?.id
        model.set @['Model'][coll]['read'] id
    else if model.value?
      model.set undefined
    return
