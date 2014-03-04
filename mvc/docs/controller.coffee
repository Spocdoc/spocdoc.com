module.exports =
  view: 'with_sidebar'

  outlets: [
    'id'
    'doc': (id) -> @Model['docs'].read id
    'title': -> @doc.get('title')
  ]

  $main: -> new @View['md/article'] this, 'main', doc: => @doc
  $sidebar: -> new @View['sidebar_split'] this, 'sidebar',
    top: new @Controller['docs/sidebar_top'] this, 'sidebarTop'
    bottom: new @Controller['docs/sidebar_tabs'] this, 'sidebarTabs'
