typeToClass = require 'manifest_mvc/type_to_class'

module.exports =
  view: 'tab_rows':
    defaultTabs: [
      'Outline'
      'Media'
    ]
    orderedTabs: -> @session.get('user')?.get('priv')?.get('docTabs')
    rowStarts: -> @session.get('user')?.get('priv')?.get('docTabStarts')

  getCell: (tab) ->
    tabClass = typeToClass tab
    @controllers[tab] ||= new @View["docs/sidebar_tabs/#{tabClass}"] this, "#{tabClass}_content"

  freeCell: (tab) ->

