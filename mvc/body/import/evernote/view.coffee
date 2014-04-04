oauth = require 'connect_oauth'
debug = global.debug 'app:oauth'
_ = require 'lodash-fork'

module.exports =
  mixins: 'mixins/css_slides'

  internal: [
    'oauthError'
    'importError'
    'importDone'
  ]

  $evernote: link: ['startOauth', 'evernote']
  $oauthError: 'text'
  $importError: 'text'
  $noteList: view: -> @controllers['noteList'] ||= new @View['import_list'] this, 'noteListView', name: 'note(s)'
  $progress: view: -> @controllers['progress'] ||= new @View['progress_meter'] this, 'progress'

  outletMethods: [
    (importDone) ->
      if importDone
        if @ace.onServer
          @$done.html """<p>Done!</p>"""
        else
          @$done.html """<p>Done!</p><a href="#{$.link(this, 'importAgain')}">Import again</a>"""
          @$done.find('a').on 'click', =>
            @importAgain()
            false
      else
        @$done.html @templates.spinner
      return
  ]

  setNotebooks: (list) ->
    html = ''

    for notebook in list
      html += """<li><a data-guid=#{_.quote notebook.guid} href="javascript:void(0);">#{_.unsafeHtmlEscape notebook.name}</a></li>"""

    @$notebookList.html html
    return

  importNotes: (list) ->
    progress = @controllers['progress'].fraction
    noteList = @controllers['noteList']
    session = @session.get()

    i = -1; e = list.length

    handle = (err) =>
      progress.set (if e is 0 then 1 else (i+1)/e)
      note = list[i]
      noteList.add (note.title or "note #{note.guid}"), !err
      importNote()

    importNote = =>
      if ++i is e
        @importDone.set true
        return

      note = list[i]
      session.oauthService @oauth, 'importNote', note.guid, handle

    importNote()
    return

  importAgain: ->
    @goToSlide(1)
    @controllers['noteList'].clear()
    @controllers['progress'].fraction.set 0
    @importDone.set false
    return

  startOauth: (service) ->
    return if @inviting

    $li = @$[service].parent()
    $li.addClass 'in-progress'

    @$oauth.removeClass 'has-error'

    oauth.startOauth service, (err, info) =>

      debug "oauth got err,info",err,info

      if err? or !info
        @$oauth.addClass 'has-error'
        @oauthError.set "Connecting with #{service} failed."
        $li.removeClass 'in-progress'
      else
        @$oauth.removeClass 'has-error'
        @inviting = true

        @session.get().oauthService info, 'listNotebooks', (err, list) =>
          delete @inviting
          $li.removeClass 'in-progress'

          if err
            @oauthError.set "Oops! There was an error using the #{service} API. Try connecting again."
            return

          @oauth = info
          @setNotebooks list
          @nextSlide()

      return

  constructor: ->
    @$notebookList.on 'click', 'a', (event) =>
      return unless (target = event.target) and target.getAttribute and (notebookId = target.getAttribute('data-guid'))?
      @nextSlide()

      @session.get().oauthService @oauth, 'listNotes', notebookId, (err, list) =>
        if err?
          @importError.set "There was an error listing the notes. Try connecting again."
          return

        @importNotes list
        return

      return false

