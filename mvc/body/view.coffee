regexOn = /(?:^|\s+)on(?:$|\s+)/g

tabs = [
  'about'
  'blog'
  'explore'
  'connect'
  'docs'
  'search'
]

module.exports =
  outlets: [
    'menu'
    'dialog'
    'content'
    'tab'
  ]

  internal: [
    'dialogView'
  ]

  $content: 'view'
  $menuButton: linkdown: ['toggleMenu', 'on']
  $logIn: linkup: ['toggleMenu', 'login']
  $logInBack: linkdown: ['toggleMenu','login']
  $inviteMe1: linkdown: ['toggleDialog','inviteMe']
  $inviteMe2: linkdown: ['toggleDialog','inviteMe']
  $dialog: view: 'dialogView'

  $about: link: ['depute','showPage','about']
  $blog: link: ['depute','showPage','blog']
  $explore: link: ['depute','showPage','explore']
  $connect: link: ['depute','showPage','connect']
  $docs: link: ['depute','showPage','docs']
  $search: link: ['depute','showPage','search']
  $logo: link: ['depute','showPage','']
  
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
      @$footer.toggleClass 'blurred', blur

    (tab) ->
      for t in tabs
        @$[t].toggleClass 'selected', !!(t is tab)
      return

  ]

