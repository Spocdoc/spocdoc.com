module.exports =
  inlets: [
    'main'
    'sidebar'
  ]

  $main: 'view'
  $sidebar: 'view'

  $sidebarChevron: linkdown: 'toggleSidebar'

  toggleSidebar: ->
    @$root.toggleClass 'sidebar-shown'


