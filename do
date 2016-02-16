#!/bin/bash
if [[ $1 =~ apply_gitignore|update_repo_files|pull_from_servers|push_to_servers|sync_repo|cap|sidekiq_restart|puma_restart ]];
then
  if [ "$2" != "" ]; then
    ./bin/$1 "$2"
  else
    ./bin/$1
  fi
fi
