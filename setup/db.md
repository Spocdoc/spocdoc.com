# database setup

	db.users_priv.ensureIndex({email: 1},{unique: true, name: 'email'})
	db.users_priv.ensureIndex({oauthProvider: 1, oauthId: 1},{unique: true, name: 'oauth'})

	db.users.ensureIndex({username: 1},{unique: true, name: 'username'})

	db.docs.ensureIndex({text: "text", title: "text", headers: "text", tags: 1, date: 1}, {weights: {title: 1000, tags: 100, headers: 10, text: 1}, name: 'text'})

	db.docs.ensureIndex({tags:1},{name: 'tags'})
	db.docs.ensureIndex({date:1},{name: 'date'})

## remove the current documents

    db.docs.remove({_id: {$in: [ ObjectId('534fe3011507eda475000001'), ObjectId('534fd4540d1e18a862000001'), ObjectId('534d70b22d62594912000003'), ObjectId('6507bdb347de85cf373121da'), ObjectId('5349cac3853b9a2478bd8c6d') ]}})

## replace with file

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

