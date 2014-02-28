Outlet = require 'outlet'

module.exports =
  start: ->

  list: (add) ->
    add '?:menu'
    add '?:dialog'
    add '?dsb=:docsShowSidebar'
    add '/', page: ''
    add '/about', page: 'about'
    add '/blog', page: 'blog'
    add '/explore', page: 'explore'
    add '/search', page: 'search'
    add '/connect', page: 'connect'

  configure: ->
    @map
      page: '/page'
      menu: '/$menu'
      dialog: '/$dialog'
      docsShowSidebar: '/docs/$showSidebar'

