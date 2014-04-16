#!/usr/bin/env coffee

invite = require './invite'
fs = require 'fs'

ObjectId = (id) -> id
DBRef = -> ''
ISODate = (txt) -> new Date txt

user = {
        "_id" : ObjectId("534eb6143dfc8a2236000001"),
        "_v" : 1,
        "username" : " 534eb6143dfc8a2236000001",
        "priv" : DBRef("users_priv", ObjectId("534eb6143dfc8a2236000001")),
        "picture" : null,
        "active" : 0,
        "name" : null
}

priv = {
        "_id" : ObjectId("534eb6143dfc8a2236000001"),
        "_v" : 1,
        "email" : "baz@bo.com",
        "created" : ISODate("2014-04-16T16:55:48.899Z"),
        "invite" : "96b6b543ccb46687560082b2",
        "oauthId" : ObjectId("534eb6143dfc8a2236000001")
}

invite user, priv, (err, obj) ->
  return console.error err if err?

  fs.writeFileSync './test.html', obj.html
  fs.writeFileSync './test.txt', obj.text
