regexOn = /(?:^|\s+)on(?:$|\s+)/g

module.exports =
  outlets: [
    'menu'
  ]

  $menuButton: linkdown: ['toggleMenu', 'on']
  $logIn: linkup: ['toggleMenu', 'login']
  $logInBack: linkdown: ['toggleMenu','login']
  
  toggleMenu: (which) ->
    menu = @menu.get() || ''
    if menu is menuNew = menu.replace ///(?:^|\s+)#{which}(?:$|\s+)///g, ' '
      # currently off
      menu = menu.split(' ').concat(which).join(' ')
    else
      menu = menuNew

    @menu.set menu
    return

  outletMethods: [
    (menu) ->
      @$mainMenu.attr 'data-menu',(menu||'')
  ]

