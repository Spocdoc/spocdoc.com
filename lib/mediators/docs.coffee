module.exports = (Base) ->
  class Handler extends Base
    create: (doc, cb) -> super

    read: (id, version, query, limit, sort, cb) ->
      # return cb.reject "Invalid session" unless @session.invited or @session.usersPriv
      super

    update: (id, version, ops, cb) -> super

    delete: (id, cb) -> super

    distinct: (query, key, cb) -> super

