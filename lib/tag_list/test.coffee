#!/usr/bin/env coffee

TagList = require './'

tl = new TagList()
tl.add "people/foo"
tl.add "People/baz"
tl.add "People/bAz"
tl.add "yo"
tl.add "yo"
tl.add "Yo"
tl.add "yo"
console.log tl

console.log tl.case 'people/foo'
console.log tl.case 'people/baz'
