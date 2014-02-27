Outlet = require 'outlet'

module.exports =
  start: ->

  list: (add) ->
    add '?:menu'
    add '/'

  configure: ->
    @map
      menu: '/$menu'

