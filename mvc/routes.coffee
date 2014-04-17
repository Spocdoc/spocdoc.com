Outlet = require 'outlet'
_ = require 'lodash-fork'

regexSpace = new RegExp _.regexp_s, 'g'
regexNonUrl = /[^a-zA-Z0-9_-]/g

toSlug = (name) ->
  (name||'').replace(regexSpace, '-').replace(regexNonUrl,'')

module.exports =
  start: ->
    @Model['sessions'].initSession this
    @globals.user = new Outlet (->@session.get('user')), this, true
    @globals.userPriv = new Outlet (->@globals.user.get('priv')), this, true
    @ace.loggedIn = new Outlet (->@globals.user.get('active')), this, true

    unless @ace.onServer
      $window = $ global
      scrollEvent = => @scrollTop.set @_scrollTop = $window.scrollTop()
      $('body').on 'touchmove', scrollEvent
      $window.on 'scroll', scrollEvent unless $.hasTouch()

    return

  afterPush: (options) ->
    unless options and options.setScroll is false
      @scrollTop.set 0
    return

  list: (add) ->
    add '?:menu'
    add '?:dialog'
    add '?dsb=:docsShowSidebar'
    add '?ssb=:searchShowSidebar'
    add '?is=:importSource'
    add '#s=:scrollTop'
    add '?:iid&:it'

    add 'landing', '/', page: ''
    # add 'about', '/about', '?:q', page: 'about'
    add '/explore', page: 'explore'
    add '/connect', page: 'connect'
    add '/contact_us', page: 'contactUs'

    add 'search', '/updates/:number', '?:q', '#ds1=:dateScrollTop&ds2=:dateScrollBottom&ds3=:dateScrollBot', page: 'blog'
    add 'search', '/updates', '?:q', '#ds1=:dateScrollTop&ds2=:dateScrollBottom&ds3=:dateScrollBot', page: 'blog'

    add 'search', '/search/:number', '?:q', '#ds1=:dateScrollTop&ds2=:dateScrollBottom&ds3=:dateScrollBot', page: 'search'
    add 'search', '/search', '?:q', '#ds1=:dateScrollTop&ds2=:dateScrollBottom&ds3=:dateScrollBot', page: 'search'

    add 'docs', '/doc/:title?/:id', '?:q', page: 'docs'

    add 'admin', '/admin', page: 'admin'

  configure: ->
    slug = @var '/docs/main/title'
    slug.addOutflow =>
      @docs['title'].set toSlug slug.value

    unless @ace.onServer
      $window = $ global

    scrollTop = 0
    setScroll = =>
      $window.scrollTop(scrollTop)
      return
    @scrollTop.addOutflow =>
      unless @ace.onServer or @_scrollTop is scrollTop = @scrollTop.value or 0
        Outlet.atEnd setScroll
      return

    @map
      iid: '/invitedId'
      it: '/inviteToken'
      page: '/page'
      menu: '/$menu'
      dialog: '/$dialog'
      importSource: '/importContent/choices/$selected'
      docsShowSidebar: '/docs/$showSidebar'
      searchShowSidebar: '/search/$showSidebar'
      # about:
      #   q: '/static/field/$search'
      search:
        q: '/search/field/$search'
        number: '/search/number'
        dateScrollTop: '/search/datesContent/calendar/$scrollDateTop'
        dateScrollBottom: '/search/datesContent/calendar/$scrollDateBottom'
        dateScrollBot: '/search/datesContent/calendar/$scrollBot'
      docs:
        q: '/docs/field/$search'
        id: '/docs/id'

        
        # resource: ['/docs/doc','docs','title']

