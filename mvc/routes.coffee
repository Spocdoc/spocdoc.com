Outlet = require 'outlet'

module.exports =
  start: ->
    @Model['sessions'].initSession this
    @ace.loggedIn = new Outlet (->
      @session.get('user')?.get()?.present), this, true

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
    add '/contact_us', page: 'contactUs'

  configure: ->
    @map
      page: '/page'
      menu: '/$menu'
      dialog: '/$dialog'
      docsShowSidebar: '/docs/$showSidebar'

