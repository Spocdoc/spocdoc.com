async = require 'async'
debug = global.debug "ace:app:users_priv"
diff = require 'diff-fork'


IMMUTABLE_FIELDS = [
  '_id'
  '_v'
  'email'
  'password'
]

FILLER_TEXT = [
  """
  Edit me!

  Hey @spocdoc, I just created a doc!

  #example
  """
  """
  Title: Example doc

  #example
  
  Edit me! Did you know you can add titles, too?
  """
]

module.exports = (Base) ->
  class Handler extends Base
    read: (id, version, query, limit, sort, cb) ->
      return unless @handlers.sessions._checkUser id, cb
      super

    update: (id, version, ops, cb) ->
      return unless @handlers.sessions._checkUser id, cb

      cb.validate = (from, ops, to, next) =>
        if ops
          for op in ops
            if op.k in IMMUTABLE_FIELDS
              return next new Error("Can't change those fields directly")

        if !to.draftFiller?
          @_chooseDraftFiller (err, filler) ->
            moreOps = diff to, filler, path: ['draftFiller']
            to.draftFiller = filler
            next null, moreOps
        else
          next()
      super

    _chooseDraftFiller: (cb) ->
      cb null, FILLER_TEXT[Math.floor Math.random() * FILLER_TEXT.length]

