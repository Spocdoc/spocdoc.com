require 'es5'
{makeId} = require 'lodash-fork'

module.exports =
  outlets: [
    'query'
    'spec'
    'words'
    'specTags'
    'dateStart'
    'dateEnd'
    'frozen'
  ]

  words: (spec) -> part.value for part in spec or [] when part.type is 'text'

  $hashes: ->
    if @frozen.get()
      []
    else
      ''+hash for hash in @query.get().results.get()

  getCell: (hash, index) ->
    cell = @cells[hash] ||= new @View['search/results/doc'] this, hash
    cell.model.set @query.get().results.get()[index]
    cell.words.set @words
    cell.specTags.set @specTags
    cell.dateStart.set @dateStart
    cell.dateEnd.set @dateEnd
    cell

  freeCell: (hash) ->
    if cell = @cells[hash]
      cell.model.set undefined
      cell.words.unset @words
      cell.specTags.unset @specTags
      cell.dateStart.unset @dateStart
      cell.dateEnd.unset @dateEnd
      # delete @cells[hash]
    return

  constructor: ->
    @cells = {}

