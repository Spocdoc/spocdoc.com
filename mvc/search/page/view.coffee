module.exports =
  outlets: ['field', 'results']
  $field: 'view'
  $results: 'view'

  outletMethods: [
    (inWindow, field) ->
      if inWindow and !$.mobile
        field?.$search?.focus()
      return

  ]
