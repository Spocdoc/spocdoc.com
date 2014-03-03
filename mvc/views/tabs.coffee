utils = require '../../lib/utils'
typeToClass = require 'manifest_mvc/type_to_class'
debug = global.debug 'app:tabs'

dragTarget = null
dragSpec = null

module.exports =
  inlets: [
    'defaultTabs'
    'orderedTabs'
    'clickOrders'
  ]

  outlets: [
    'selected': (tabs, orderedTabs) ->
      unless tabs and tabs.length
        null
      else
        return tabs[0] if @ace.onServer
        current = @selected.value
        return current if current in tabs

        if arr = @clickOrders.value
          j = arr.length
          while --j >= 0
            return tab if (tab = arr[j]) in tabs

        tabs[0]
  ]

  internal: [
    'tabs': (defaultTabs, orderedTabs) ->
      return orderedTabs unless defaultTabs
      if orderedTabs
        @orderedTabs.set tabs = utils.defaultArr defaultTabs, orderedTabs
      else
        tabs = defaultTabs
      tabs

    'tabList': (tabs) ->
      return if dragTarget

      # unless @ace.booting and @template.bootstrapped
      html = ''
      if tabs
        for tab in tabs
          className = typeToClass(tab)
          html += """<li data-tab="#{tab}" draggable="true"><a title="#{tab}" data-tab="#{tab}" draggable="false" class="#{className}" href="#{$.link(this,'select',tab)}"><span>#{tab}</span></a></li>"""
      @$tabList.html html
      # always toggle, even if booting
      @$tabList['removeClass!'] 'no-labels'
      @$tabList['toggleClass!'] 'no-labels',(@$tabList.width() > @$root.width())

      unless @ace.onServer
        li = @$tabList[0].firstChild
        i = 0

        while li
          do ($li = $ li) =>
            midpoint = null
            left = null
            overSide = ''
            spec =
              view: this
              tab: tabs[i]

            $li.on 'dragenter', (event) ->
              return if this is dragTarget
              overSide = ''
              midpoint = null
              return

            $li.on 'dragover', (event) ->
              # only allow moving if they share the same parent
              return unless dragTarget and dragSpec and dragSpec.view.aceParent is spec.view.aceParent

              oe = event.originalEvent
              oe.dataTransfer.dropEffect = 'move'

              unless this is dragTarget
                midpoint ?= $li.width()/2
                unless (offset = oe.offsetX)?
                  left ?= $li.offset().left
                  offset = oe.clientX - left

                # debug "midpoint: ",midpoint," vs ",offset

                if offset >= midpoint
                  put = 'right' if overSide isnt 'right'
                else unless overSide is 'left'
                  put = 'left'

                if put
                  dragTabs = dragSpec.view.tabs.value
                  thisTabs = spec.view.tabs.value

                  dragTabsOutlet = dragSpec.view.orderedTabs
                  thisTabsOutlet = spec.view.orderedTabs

                  dragTab = dragSpec.tab
                  thisTab = spec.tab

                  # prevent dragging last remaining tab
                  return false unless dragTabs.length > 1

                  # debug "drag tabs",dragTabs
                  # debug "this tabs",thisTabs

                  if (overSide = put) is 'right'
                    $li.after dragTarget
                  else
                    $li.before dragTarget

                  if dragTabs and ~(index = dragTabs.indexOf(dragTab))
                    dragTabs.splice(index, 1)
                    if dragTabsOutlet.value is dragTabs
                      dragTabsOutlet.modified()
                    else
                      dragTabsOutlet.set dragTabs

                  if thisTabs and ~(index = thisTabs.indexOf(thisTab))
                    thisTabs.splice((if put is 'left' then index else index+1), 0, dragTab)
                    if thisTabsOutlet.value is thisTabs
                      thisTabsOutlet.modified()
                    else
                      thisTabsOutlet.set thisTabs

                  if dragSpec.view isnt spec.view
                    rootWidth = spec.view.$root.width()

                    if ($dsList = dragSpec.view.$tabList).hasClass 'no-labels'
                      # see if labels can be applied now
                      $dsList.removeClass 'no-labels'
                      if $dsList.width() > rootWidth
                        $dsList.addClass 'no-labels'

                    unless ($list = spec.view.$tabList).hasClass 'no-labels'
                      # see if labels should be removed now
                      if $list.width() > rootWidth
                        $list.addClass 'no-labels'

                  # debug "NOW drag tabs",dragTabs
                  # debug "NOW this tabs",thisTabs

                  (dragSpec.view = spec.view).selected.set dragTab

              false

            ul = null

            $li.on 'dragstart', (event) ->
              dt = event.originalEvent.dataTransfer
              dt.effectAllowed = 'move'
              dt.setData 'text/plain', ''

              dragTarget = this
              dragSpec = spec

              (ul = $li.closest('ul')).addClass 'dragging'
              return

            $li.on 'dragend', (event) ->
              ul?.removeClass 'dragging'
              dragTarget = dragSpec = null
              return

          li = li.nextSibling
          ++i

      html

    'content': (selected, tabList) -> # tabList dependence is a hack so this calculates *after* the html is added
      if selected
        if (a = @$tabList.find(".#{typeToClass selected}")).length
          a.parent().addClass('selected')

      if (os=@oldSelected) and os isnt selected and (a = @$tabList.find(".#{typeToClass os}")).length
        a.parent().removeClass('selected')
        @depute 'freeCell', os

      if @oldSelected = selected
        @depute 'getCell', selected
      else
        null
  ]

  $content: 'view'

  $tabList: linkdown: ['a', ($target) -> ['select',$target.attr('data-tab')]]

  select: (selected) ->
    @selected.set selected
    unless arr = @clickOrders.value
      @clickOrders.set [selected]
    else
      if ~(index = arr.indexOf(selected))
        arr.splice(index,1)
      arr.push selected
      @clickOrders.modified()
    return true


