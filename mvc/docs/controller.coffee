module.exports =
  view: 'with_sidebar'

  outlets: [
    'doc'
  ]

  $main: -> new @View['test'] this, 'main'
  $sidebar: -> new @View['sidebar_split'] this, 'sidebar',
    top: new @View['docs/sidebar_top'] this, 'sidebarTop'
    bottom: new @Controller['docs/sidebar_tabs'] this, 'sidebarTabs'

  constructor: ->
    # @sidebar.set sidebar = new @View['document/sidebar'] this, 'sidebar'
    # @sidebarTabs.set sidebarTabs = new @Controller['document/sidebar_tabs'] this, 'sidebar_tabs'
    return
