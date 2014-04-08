Conflict = require 'ace_mvc/lib/error/conflict'

module.exports =
  mixins: 'mixins/img_uploader'

  internal: [
    'error'
  ]

  $error: 'text'

  $done: link: ['done']
  $enlarge: link: ['done', true]
  $cancel: link: ['cancel']

  $content: 'view': -> @controllers['article']

  outletMethods: [
    (error) -> @$errorContainer.toggleClass 'has-error', !!error
  ]

  cancel: ->
    @userPriv.get('draft')?.set ''
    @depute 'toggleMenu', 'plus', false
    return

  done: (enlarge) ->
    return unless (article = @controllers['article']) and userPriv = @userPriv.get()
    @error.set ''

    userPriv.draftDone (err, docId) =>
      if err?
        if err instanceof Conflict
          @error.set "There has been a conflict saving the draft. If you want to recover the current document, you'll have to copy the text to an outside editor, reload this page and compare the current draft with your old draft."
        else
          # switch err.code
          #   else
          @error.set "Oops! There was an internal error. We're looking into it. Please try again later."
        return

      @depute 'toggleMenu', 'plus', false

      if enlarge
        @depute 'showDoc', docId, 0, 0
      return

    return

  constructor: ->
    @controllers['article'] = new @View['md/article'] this, 'article',
      md: -> @userPriv.get('draft')
      editable: true




