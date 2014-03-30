module.exports =
  view: 'twoup'

  internal: [
    rhs: (selected) ->
      selected ||= 'text_files'
      @controllers[selected] ||= new @View["body/import/#{selected}"] this, selected
  ]

  $lhs: -> @lhs

  $rhs: -> @rhs

  constructor: ->
    @lhs = new @View['dialog_choices'] this, 'choices',
      header: 'Source'
      description:
        """Choose the source from which you'd like to import documents."""
      defaultSelected: 'text_files'
      choices: [
        "Text Files"
        # "Drop Box"
        # "Google Drive"
        "Evernote"
      ]

    @selected = @lhs.selected
