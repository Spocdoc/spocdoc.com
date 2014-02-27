regexOn = /(?:^|\s+)on(?:$|\s+)/g

module.exports =
  outlets: [
    'menu'
    'dialog'
  ]

  internal: [
    'dialogView'
  ]

  $menuButton: linkdown: ['toggleMenu', 'on']
  $logIn: linkup: ['toggleMenu', 'login']
  $logInBack: linkdown: ['toggleMenu','login']
  $inviteMe1: linkdown: ['toggleDialog','inviteMe']
  $inviteMe2: linkdown: ['toggleDialog','inviteMe']
  $inviteMe3: linkdown: ['toggleDialog','inviteMe']
  $dialog: view: 'dialogView'
  
  toggleMenu: (which) ->
    menu = @menu.get() || ''
    if menu is menuNew = menu.replace ///(?:^|\s+)#{which}(?:$|\s+)///g, ' '
      # currently off
      menu = menu.split(' ').concat(which).join(' ')
    else
      menu = if menuNew is ' ' then '' else menuNew

    @menu.set menu
    return

  toggleDialog: (which, onOff) ->
    which ||= ''

    if onOff?
      if onOff
        @dialog.set which
      else
        @dialog.set ''
    else
      if @dialog.get() is which
        @dialog.set ''
      else
        @dialog.set which
    return

  outletMethods: [
    (menu) ->
      @$mainMenu.attr 'data-menu',(menu||'')

    (dialog) ->
      @dialogView.set dialog = if dialog then @depute('getController',dialog) else null
      blur = !!dialog

      $('body').toggleClass 'no-scroll', blur

      @$bar.toggleClass 'blurred', blur
      @$content.toggleClass 'blurred', blur
      @$centeredContent.toggleClass 'blurred', blur
      @$footer.toggleClass 'blurred', blur


  ]

