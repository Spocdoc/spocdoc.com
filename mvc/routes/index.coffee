Outlet = require 'outlet'

module.exports =
  methods:
    resource: require './resource'

  start: ->
    @Model['sessions'].initSession this
    @ace.loggedIn = new Outlet (->
      @session.get('user')?.get()?.present), this, true

  list: (add) ->
    add '?:menu'
    add '?:dialog'
    add '?dsb=:docsShowSidebar'
    add '?ssb=:searchShowSidebar'

    add '/', page: ''
    add '/about', page: 'about'
    add '/explore', page: 'explore'
    add '/search', page: 'search'
    add '/connect', page: 'connect'
    add '/contact_us', page: 'contactUs'

    add 'search', '/blog/:number', '?:q&:tab&ts=:tagSlides', '#ds1=:dateScrollTop&ds2=:dateScrollBottom&ds3=:dateScrollBot', page: 'blog'
    add 'search', '/blog', '?:q&:tab&ts=:tagSlides', '#ds1=:dateScrollTop&ds2=:dateScrollBottom&ds3=:dateScrollBot', page: 'blog'

    add 'docs', '/docs/:title?/:id', page: 'docs'

  configure: ->
    @map
      page: '/page'
      menu: '/$menu'
      dialog: '/$dialog'
      docsShowSidebar: '/docs/$showSidebar'
      searchShowSidebar: '/search/$showSidebar'
      search:
        q: '/search/field/$search'
        number: '/search/number'
        tagSlides: '/search/sidebar/tags_content/$slides'
        dateScrollTop: '/search/sidebar_tabs/dates_content/calendar/$scrollDateTop'
        dateScrollBottom: '/search/sidebar_tabs/dates_content/calendar/$scrollDateBottom'
        dateScrollBot: '/search/sidebar_tabs/dates_content/calendar/$scrollBot'
      docs: resource: ['/docs/doc','docs','title']

