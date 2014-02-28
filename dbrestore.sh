#!/bin/zsh

main()
{
  mongorestore --host /tmp/mongodb-27017.sock 
  
}

main "$@"
