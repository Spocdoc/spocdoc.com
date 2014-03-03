module.exports =
  outlets: ['hashes']
  template: 'blank'

  outletMethods: [
    (hashes) ->
      cells = @cells

      newHashes = hashes || []
      oldHashes = @oldHashes
      @oldHashes = newHashes
      removed = {}
      kept = {}

      removed[hash] = i for hash, i in oldHashes
      kept[hash] = j for hash, j in newHashes

      nextCell = cells[oldHash = oldHashes[i = 0]]

      j = 0
      jE = newHashes.length
      while j < jE
        newHash = newHashes[j]
        if oldHash is newHash
          delete removed[oldHash]
          ++j
        else if !oldHash? or ( (dj = kept[oldHash]-j) > 0 and !((di = removed[newHash]-i)<dj) )
          if cell = cells[newHash]
            delete removed[newHash]
          else
            cell = cells[newHash] = @depute 'getCell', newHash, j
          if nextCell
            cell.insertBefore(nextCell, this)
          else
            cell.appendTo(@$root, this)
          ++j
          continue
        nextCell = cells[oldHash = oldHashes[++i]]

      for hash of removed
        cells[hash].detach()
        delete cells[hash]
        @depute 'freeCell', hash

      return
  ]

  constructor: ->
    @cells = {}
    @oldHashes = 0
