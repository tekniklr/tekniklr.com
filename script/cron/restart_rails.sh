#!/bin/bash
# restart rails if Dreamhost has killed it (as it does)

home=/home/tekniklr
app_root=${home}/rails.tekniklr.com/current/
pid_file=${app_root}/tmp/pids/server.pid
rvm_path=${home}/.rvm/bin/rvm

# function to actually restart delayed_job
restart_rails () {
  echo "Restarting rails..."
  cd $app_root
  RAILS_ENV=production $rvm_path default do bundle exec bin/rails restart
  echo "Restarted rails!"
}

# does rails THINK it is running
if [ -s  $pid_file ]; then
  # yes - but do we actually have a process to match that pid?
  if ! ps -p `cat $pid_file` > /dev/null 2>&1
    # yes - we have a running server to match rails' view of reality
  then
    # no - restart
    restart_rails
  fi
else
  # no - restart
  echo "No rails server pid file"
  restart_rails
fi