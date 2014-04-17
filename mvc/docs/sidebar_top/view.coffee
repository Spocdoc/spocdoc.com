module.exports =
  outlets: [
    'search'
    'editable'
    'pub'
  ]

  $search: 'view'
  $tools: linkdown: ['toggleTools']
  $delete: linkup: ['runMenu', 'deleteDoc']

  toggleTools: -> @$tools.toggleClass 'active'

  runMenu: (method) ->
    @$tools.removeClass 'active'
    @depute method
    return

  outletMethods: [
    (editable) ->
      if editable
        @$editable.text('editable').addClass 'on'
      else
        @$editable.text('not editable').removeClass 'on'
      return
        
    (pub) ->
      if pub
        @$public.text('public').addClass 'on'
      else
        @$public.text('not public').removeClass 'on'
      return
  ]
