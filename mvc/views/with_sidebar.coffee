module.exports =
  inlets: [
    'main'
    'sidebar'
    'showSidebar'
  ]

  $main: 'view'
  $sidebar: 'view'
  $sidebarChevron: linkdown: 'toggleSidebar'

  outletMethods: [
    (showSidebar) -> @$root.toggleClass 'sidebar-shown', !!showSidebar
  ]

  toggleSidebar: -> @showSidebar.set !@showSidebar.get()


