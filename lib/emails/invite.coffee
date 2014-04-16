_ = require 'lodash-fork'
fs = require 'fs'
Uri = require 'uri-fork'
async = require 'async'
juice = require 'juice'
cache = require './cache'
path = require 'path'
markdown = require 'marked-fork/render'

module.exports = (user, priv, cb) ->
  async.waterfall [
    (next) =>
      cache __filename, next

    (htmlFn, textFn, css, next) =>

      (uri = new Uri).query
        it: priv.invite
        iid: ''+user._id
      uri = """https://synop.si#{uri}"""

      locals =
        name: user.name
        email: priv.email
        uri: uri
        welcome: """You've been invited to join Synopsi, the online blogging, note-taking, and writing platform. Now is your chance to try it out and join the community. It's a super-fast and elegant way of storing and finding your content from anywhere. You'll love it."""
        button: "Get Started"
        markdown: markdown

      obj =
        to: priv.email
        subject: "Your Synopsi Invitation"
        html: juice htmlFn(locals), css
        text: textFn? locals

      next null, obj

  ], cb

