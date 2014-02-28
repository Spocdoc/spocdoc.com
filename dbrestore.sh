#!/bin/zsh

main()
{
  mongorestore --host /tmp/mongodb-27017.sock $1
  
}

main "$@"
