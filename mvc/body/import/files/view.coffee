_ = require 'lodash-fork'

module.exports =
  mixins: 'mixins/css_slides'

  internal: [
    'fileList'
    'canSubmit': (fileList) -> !!(fileList and fileList.length)
    'importDone'
  ]

  $fileList: view: -> @controllers['fileList'] ||= new @View['import_list'] this, 'fileListView', name: 'file(s)'
  $noteList: view: -> @controllers['noteList'] ||= new @View['import_list'] this, 'noteListView', name: 'note(s)'

  $progress: view: -> @controllers['progress'] ||= new @View['progress_meter'] this, 'progress'
  $cssSlides: link: ['startImporting']

  outletMethods: [
    (canSubmit) -> @$step1Next.toggleClass 'can-submit', !!canSubmit

    (fileList) ->
      if fileList
        @$fileList.css 'display', 'block'
        @controllers['fileList'].add file.name for file in fileList
      else
        @$fileList.css 'display', 'none'

      return

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

  importAgain: ->
    @prevSlide()
    @fileList.set []
    if @ace.onServer
      @$fileChooser[0].files = null
    else
      @$fileChooser.replaceWith @$fileChooser = @$fileChooser.clone(true)
    @controllers['fileList'].clear()
    @controllers['noteList'].clear()
    @importDone.set false
    @controllers['progress'].fraction.set 0
    return

  addFiles: (fileList) ->
    arr = @fileList.get()?.concat() || []
    if fileList[0] # fileList may be an array-like object
      arr.push file for file in fileList
    else
      arr.push fileList
    @fileList.set arr
    return

  startImporting: ->
    return false unless @canSubmit.value
    @nextSlide()

    return if @importing
    @importing = true

    progress = @controllers['progress'].fraction
    noteList = @controllers['noteList']

    if (fileList = @fileList.get()) and $.hasFileAPI()
      fileReader = new $.FileReader()
      file = 0
      len = fileList.length
      i = -1

      options =
        nameIsTitle: @$nameIsTitle.prop 'checked'

      done = =>
        @importDone.set true
        @importing = false
        return

      nextFile = (event) =>
        if event
          @Model['docs'].import event.target.result, file.name, options, (err, name) =>
            noteList.add name, !err

        progress.set (i+1)/len

        return done() if ++i is len
        file = fileList[i]
        fileReader.readAsText file # TODO this will have to be an ArrayBuffer instead...
        return

      fileReader.onload = nextFile
      nextFile()

    return

  constructor: ->
    unless @ace.onServer
      @$fileChooser.on 'change', =>
        @addFiles fileList if fileList = @$fileChooser[0].files
        return

      if $.hasDragDrop()
        @$dropMessage.text """You can drop your files here."""

        @$dropZone.on 'dragleave', => @$step1.removeClass 'dragenter'
        @$step1.on 'dragenter', (event) =>
          @$step1.addClass 'dragenter'
          event.stopPropagation()
          return

        @$dropZone.on 'dragover', (event) => false

        @$dropZone.on 'drop', (event) =>
          @$step1.removeClass 'dragenter'
          @addFiles fileList if fileList = event.originalEvent?.dataTransfer?.files
          @$step1Instructions.text "Drag them here."
          @$fileChooser.css 'display', 'none'
          false
    return

