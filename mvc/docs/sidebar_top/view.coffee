module.exports =
  outlets: [
    'search'
    'editable'
  ]

  $search: 'view'

  outletMethods: [
    (editable) ->
      if editable
        @$editable.text('editable').addClass 'can-edit'
      else
        @$editable.text('not editable').removeClass 'can-edit'
      return
        
  ]
