# database setup

	db.users_priv.ensureIndex({email: 1},{unique: true, name: 'email'})
	db.users_priv.ensureIndex({oauthProvider: 1, oauthId: 1},{unique: true, name: 'oauth'})

	db.users.ensureIndex({username: 1},{unique: true, name: 'username'})

	db.docs.ensureIndex({text: "text", title: "text", headers: "text", tags: 1, date: 1}, {weights: {title: 1000, tags: 100, headers: 10, text: 1}, name: 'text'})

	db.docs.ensureIndex({tags:1},{name: 'tags'})
	db.docs.ensureIndex({date:1},{name: 'date'})

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

# Mac startup

    lc start local.mongodb

 - mkdir and change permissions on </var/run/redis>

