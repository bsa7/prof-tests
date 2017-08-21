#!/bin/bash
env=$(cat env)
app_name="sibur-tests"
if [ $env == $app_name ]
then
  runned_pid=$(cat tmp/pids/puma.pid)
else
  mkdir -p /tmp/shared/pids
  mkdir -p /tmp/shared/sockets
  runned_pid=`cat /tmp/shared/pids/$app_name.pid`
fi
rm -rf tmp/cache
kill -9 $runned_pid

# Обрежем логи до последних 1000 строк
log_file=$HOME"/projects/sibur/tests/log/development.log"
tail -n 1000 $log_file > $log_file".copy"
cat $log_file".copy" > $log_file
rm $log_file".copy"

log_file=$HOME"/projects/sibur/tests/log/test.log"
tail -n 1000 $log_file > $log_file".copy"
cat $log_file".copy" > $log_file
rm $log_file".copy"


bundle exec puma -C config/puma.rb --daemon
