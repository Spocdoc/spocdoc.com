DOWN_UP_MS = 300
typeToClass = require('lodash-fork').makeCssClass

module.exports =
  inlets: [
    'selected'
    'choices'
    'header'
    'description'
    'defaultSelected'
  ]

  outlets: [
    'menu'
  ]

  outletMethods: [
    (header) ->
      @$header.text header
      @$root.toggleClass 'empty-header', !header
      return

    (description) ->
      @$root.attr 'title', description if description
      return

    (choices) ->
      return if @ace.booting and @template.bootstrapped
      html = ''
      if choices
        for choice in choices
          className = typeToClass(choice)
          html += """<li><a data-choice="#{className}" class="#{className}" href="#{$.link(this,'select',className)}">#{choice}</a></li>"""
      @$choices.html html
      return

    (selected, defaultSelected) ->
      selected ||= defaultSelected

      if (a = @$choices.find(".#{selected}")).length
        a.parent().addClass 'selected'

      if (os=@oldSelected) and os isnt selected and (a = @$choices.find(".#{os}")).length
        a.parent().removeClass 'selected'

      @oldSelected = selected
      return

    (menu) ->
      @$choicesContainer.toggleClass 'choices-menu', !!menu
      return

  ]


  $choices:
    linkdown: ['select']
    linkup: ['a', ($target) -> ['select',$target.attr('data-choice')]]

  usingMenu: ->
    @ace.onServer or parseInt(@$choices.css('border-right-width'),10)

  select: (selected) ->
    if !selected
      if @usingMenu()
        unless @menu.get()
          @downTime = Date.now()
          @menu.set true
      return

    if @usingMenu()
      if Date.now() - (@downTime||0) > DOWN_UP_MS
        if @selected.get() is selected
          @menu.set !@menu.get()
        else
          @menu.set false
        @selected.set selected
    else
      @selected.set selected

    return

  constructor: ->
    @$choices.on 'mouseover', 'a', (event) =>
      if @menu.get() and @usingMenu()
        $(event.currentTarget).addClass 'hover'
      return
    @$choices.on 'mouseout mouseup', 'a', (event) =>
      $(event.currentTarget).removeClass 'hover'
