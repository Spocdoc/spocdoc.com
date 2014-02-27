Outlet = require 'outlet'

module.exports =
  start: ->

  list: (add) ->
    add '?:menu'
    add '?:dialog'
    add '/'

  configure: ->
    @map
      menu: '/$menu'
      dialog: '/$dialog'

