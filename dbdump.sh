#!/bin/zsh

main()
{
  mongodump --host /tmp/mongodb-27017.sock -d test -c docs -q '{_id: ObjectId("6507bdb347de85cf373121da")}'
}

main "$@"
