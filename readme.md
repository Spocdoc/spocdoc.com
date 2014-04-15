# database setup

	db.users_priv.ensureIndex({email: 1},{unique: true, name: 'email'})
	db.users_priv.ensureIndex({oauthProvider: 1, oauthId: 1},{unique: true, name: 'oauth'})

	db.users.ensureIndex({username: 1},{unique: true, name: 'username'})

	db.docs.ensureIndex({text: "text", title: "text", headers: "text", tags: 1, date: 1}, {weights: {title: 1000, tags: 100, headers: 10, text: 1}, name: 'text'})

	db.docs.ensureIndex({tags:1},{name: 'tags'})
	db.docs.ensureIndex({date:1},{name: 'date'})

    db.docs.save({ "_id" : ObjectId("6507bdb347de85cf373121da"), "text" : "public:\ncss: /docs/5349cac3853b9a2478bd8c6d\n\n# What is Synopsi?\n\nTumblr, Twitter, Google Docs and Evernote all share a common core: the authoring of small or large documents that can be searched, discovered and linked together. They're all good at some things, but they're bad (or terrible) at others.\n\nThat means you have to choose and make compromises. Is what I'm doing better for a tweet or a blog post? Should I put it in Evernote, and if I do, how do I get it on my blog? What if someone wants to edit it or I want to collaborate? How do I search within all my stuff and find one part of one big file I had, wherever I am?\n\nWhat if we could combine all the best of these different services and leave the rest behind? What if you could find your stuff, share it, and create it easily and quickly everywhere?\n\n# In Progress\n\nSynopsi is a work in progress. It's currently in \"alpha\" stage and important features are missing.\n\nIf you'd like to be an early tester or are interested in finding out more about the concept and the technology, you can click the sign up button above or [Contact Us].\n\n[Contact Us]: /contact_us\n", "tags" : [ ], "date" : 20140315, "modified" : ISODate("2014-04-15T13:30:39.585Z"), "created" : ISODate("2014-04-15T13:30:39.585Z"), "words" : 198, "title" : "", "custom" : {  }, "public" : true, "editors" : [ ObjectId("534bf37ea04ca00000000002") ], "css" : "/docs/5349cac3853b9a2478bd8c6d", "_v" : 1 } )
    db.docs.save({ "_id" : ObjectId("5349cac3853b9a2478bd8c6d"), "_v" : 107, "code" : "stylus", "created" : ISODate("2014-04-12T23:22:43.687Z"), "custom" : {  }, "date" : 20140312, "editors" : [  ObjectId("533200c9cf1dd9596ed12526") ], "modified" : ISODate("2014-04-12T23:22:43.687Z"), "public" : true, "tags" : [ ], "text" : "public:\ncode: stylus\ntitle: homepage css\n\n# Introduction\n\nThis is the css file used on the homepage.\n\n# Headings\n\nHere's some styling for the headers:\n\n    h2\n    \tfont-weight bold\n    \tfont-size 1.5em\n    \tmargin-bottom 1.5em\n    \ttext-align center\n\n\n\n", "title" : "homepage css", "words" : 19 })

## commands

clear all:

	db.docs.remove()
	db.sessions.remove()
	db.users_priv.remove()
	db.users.remove()

searches:

    db.docs.runCommand("text", {search: 'punk', filter: {tags: {$all: ['people']}}})

    db.docs.runCommand("text", {search: 'jkjkjkjk'})

    db.docs.runCommand("text", {search: 'never', filter: {tags: {$all: ['furniture']}}})

    db.docs.find({tags:{$all:['furniture']}}).explain()

search with mongo 2.6.0 

    db.docs.find({$text: {$search: "coffee"}, tags: {$all: ['africa']}})

# Mac startup

    lc start local.mongodb

 - mkdir and change permissions on </var/run/redis>

