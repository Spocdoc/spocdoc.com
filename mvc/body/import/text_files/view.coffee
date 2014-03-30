_ = require 'lodash-fork'
parseNameDesc = require './parse_name_desc'
divideDocs = require './divide_docs'
templateMethods = require '../../../template_methods'

emptyFn = ->

module.exports =
  mixins:
    'mixins/editable text': ['fileNameExample', 'step2Example']
    'mixins/editable val': ['fileNameDescription', 'separatorString', 'separatorRegex']

  inlets: [
    'step'
  ]

  outlets: [
    'importUploadDone'
  ]

  internal: [
    'fileList'
    'separatorSource'
    'step2Example'
    'separatorString': -> @userPriv.get('textImportString')
    'separatorRegex': -> @userPriv.get('textImportRegex')
    'fileNameDescription': -> @userPriv.get('textImportFND')
    'separator'
    'oneDoc'
  ]

  $form: link: ['startImporting']

  separator: (separatorSource, separatorString, separatorRegex) ->
    try
      if separatorSource is 'regex'
        if cap = /^\/(.*)\/([igm]*)$/.exec separatorRegex
          return '' unless cap[1]
          return new RegExp(cap[1],cap[2])
        else
          return '' unless separatorRegex
          return new RegExp(separatorRegex)
      else
        return '' unless separatorString
        return separatorString
    catch _error
      return ''

  $step2Interp: html: (step2Example, separator) ->
    try
      return '' unless separator and step2Example
      docs[i] = _.unsafeHtmlEscape doc for doc,i in docs = divideDocs step2Example, separator
      docs.join '<hr>'
    catch _error
      return ''


  outletMethods: [
    (step, fileList, oneDoc, separator) ->
      switch step|0
        when 0, 1
          @$step1Next.toggleClass 'can-submit', !!(fileList and fileList.length)
        when 2
          @$step2Next.toggleClass 'can-submit', !!(oneDoc or separator)
      return

    (importUploadDone) ->
      if importUploadDone
        @$step4.addClass 'must-display' # for server-side upload

        if @ace.onServer
          @$step4Done.html """<p>Done!</p>"""
        else
          @$step4Done.html """<p>Done!</p><a href="#{$.link(this, 'importAgain')}">Import again</a>"""
        @$step4Done.find('a').on 'click', =>
          @importAgain()
          false

      else
        @$step4.removeClass 'must-display'
        @$step4Done.html @templates.spinner
      return

    (step) ->
      @$form.css 'left', "#{-100 * ((step||1)-1)}%"
      return

    (fileNameExample, fileNameDescription) ->
      if fileNameDescription
        @fileNameParser = func = parseNameDesc fileNameDescription
        if interp = func fileNameExample
          @$dateInterp.text if interp.date then interp.date.toDateString() else 'N/A'
          @$titleInterp.text if interp.title then interp.title else 'N/A'
        else
          @$dateInterp.text "-"
          @$titleInterp.text "-"
      else
        @fileNameParser = emptyFn
        @$dateInterp.text "-"
        @$titleInterp.text "-"
      return


    (fileList) ->
      if fileList
        @$fileCount.text "#{fileList.length} files"
        @$fileListDiv.css 'display', 'block'

        html = ""

        for file in fileList
          html += "<li>#{_.unsafeHtmlEscape file.name}</li>"

        @$fileList.html html

        @$step3Example.css 'display', 'block'
        @$step3Interp.css 'display', 'block'

        unless @fileNameExample.get()
          @fileNameExample.set (''+fileList[0].name).replace(/\.[^\.]+$/, '')
      else
        @$fileListDiv.css 'display', 'none'
        @$step3Example.css 'display', 'none'
        @$step3Interp.css 'display', 'none'
  ]


  $step1Next: link: ['next']

  $step2Back: link: ['prev']
  $step2Next: link: ['next']

  $step3Back: link: ['prev']
  $step3Next: link: ['next', 3]

  next: (step) ->
    current = @step.get() || 1
    if (link = @$["step#{current}Next"]) and link.hasClass 'can-submit'
      @step.set current + 1

    if step is 3
      @startImporting()
    return

  prev: -> @step.set (@step.get()||1)-1

  addFiles: (fileList) ->
    arr = @fileList.get()?.concat() || []
    if fileList[0] # fileList may be an array-like object
      arr.push file for file in fileList
    else
      arr.push fileList
    @fileList.set arr
    return

  addDoc: (doc) ->
    (docs = @docs ||= []).push doc
    @$step4FileList.append """<li>#{doc.linkHtml()}</li>"""
    @$step4Count.text "Added #{docs.length} docs"
    return

  importAgain: ->
    @step.set 0
    @fileList.set []
    if @ace.onServer
      @$fileChooser[0].files = null
    else
      @$fileChooser.replaceWith @$fileChooser = @$fileChooser.clone(true)
    @$step4FileList.html ''
    @$step4Count.text ''
    @importUploadDone.set false
    templateMethods.setProgress 0, @$step4Progress[0].firstChild
    delete @docs
    return

  startImporting: ->
    return if @importing
    @importing = true

    if (fileList = @fileList.get()) and $.hasFileAPI()
      oneDoc = @oneDoc.get()
      separator = @separator.get()

      fileReader = new $.FileReader()

      len = fileList.length
      progressMeter = @$step4Progress[0].firstChild
      i = -1

      meta = 0

      done = =>
        @importUploadDone.set true
        @importing = false
        return

      nextFile = (event) =>
        if event
          text = event.target.result

          if oneDoc
            try
              @addDoc @Model['docs'].build(this, text, meta)
            catch _error
              # TODO handle import error
          else
            for docText in divideDocs(text, separator)
              try
                @addDoc @Model['docs'].build(this, docText, meta)
              catch _error
                # TODO handle import error

        templateMethods.setProgress (i+1)/len, progressMeter

        return done() if ++i is len
        file = fileList[i]
        meta = @fileNameParser file.name
        fileReader.readAsText file
        return

      fileReader.onload = nextFile
      nextFile()
    return

  constructor: ->
    @$oneDoc = @$root.find "input[name='docsPerFile'][value='one']"
    @$manyDocs = @$root.find "input[name='docsPerFile'][value='many']"

    @$sepRadString = @$root.find "input[name='separatorText'][value='string']"
    @$sepRadRegex = @$root.find "input[name='separatorText'][value='regex']"

    @oneDoc.set @$oneDoc.prop('checked')

    @fileNameParser = emptyFn

    @$fileChooser.on 'change', =>
      @addFiles fileList if fileList = @$fileChooser[0].files
      return

    @$sepRadRegex.on 'change', =>
      @$separatorRegex.focus()
      @separatorSource.set 'regex'

    @$sepRadString.on 'change', =>
      @$separatorString.focus()
      @separatorSource.set 'string'

    unless @ace.onServer
      @$manyDocsDiv.css 'display', 'none'

      @$manyDocs.on 'change', =>
        @$manyDocsDiv.css 'display', 'block'
        @$separatorString.focus()
        @oneDoc.set @$oneDoc.prop 'checked'
        return

      @$oneDoc.on 'change', =>
        @$manyDocsDiv.css 'display', 'none'
        @oneDoc.set @$oneDoc.prop 'checked'
        return

      @$separatorString.on 'focus', =>
        @$sepRadString.prop 'checked', true
        @separatorSource.set 'string'

      @$separatorRegex.on 'focus', =>
        @$sepRadRegex.prop 'checked', true
        @separatorSource.set 'regex'


      @$root.find('.next').removeClass 'can-submit'
      @$step3Next[0].className += ' can-submit' # always enabled. direct because differs from server render

      if $.hasDragDrop()
        @$step1Instructions.text "Drag them here, or use the file chooser:"
        @$step1Instructions.attr "title", """
        You can drag and drop files into this area. It will highlight when you can drop the files.
        """
        @$dropMessage.text """You can drop your files here."""

        @$step1.on 'dragenter', (event) =>
          @$step1.addClass 'dragenter'
          event.stopPropagation()
          return

        @$dropZone.on 'dragover', (event) =>
          event.stopPropagation()
          event.preventDefault()
          return

        @$dropZone.on 'dragleave', =>
          @$step1.removeClass 'dragenter'

        @$dropZone.on 'drop', (event) =>
          @$step1.removeClass 'dragenter'
          @addFiles fileList if fileList = event.originalEvent?.dataTransfer?.files
          @$step1Instructions.text "Drag them here."
          @$fileChooser.css 'display', 'none'
          event.preventDefault()
          event.stopPropagation()
          false



