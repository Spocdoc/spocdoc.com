
module.exports = (Base) ->
  class Handler extends Base
    create: (doc, cb) ->
      super

    read: (id, version, query, limit, sort, cb) ->
      # return cb.reject "Invalid session" unless @session.invited or @session.usersPriv
      super

    update: (id, version, ops, cb) ->
      cb.validate = (from, ops, to, next) =>
        return unless @_requireEditor from, ops, to, next

        if !to.editors or !to.editors.length
          return next new Error("Documents must have at least one editor.")
        
        next()

      super

    delete: (id, cb) ->
      cb.validate = (from, ops, to, next) =>
        return unless @_requireEditor from, ops, to, next
        next()

      super

    distinct: (query, key, cb) -> super


    _requireEditor: (from, ops, to, next) ->
      isEditor = false

      if @session and (userId = @session.usersPriv?._id) and editors = from.editors
        userId = '' + userId
        for editor in editors when ''+editor is userId
          isEditor = true
          break

      unless isEditor
        next new Error("Only editors can change this document.")
        return false

      true

