#!/bin/bash
# restart rails if Dreamhost has killed it (as it does)

home=/home/tekniklr
app_root=${home}/rails.tekniklr.com/current/
pid_file=${app_root}/tmp/pids/server.pid

# load environment
source ${home}/.profile #> /dev/null 2>&1

# function to actually restart delayed_job
restart_rails () {
  echo "Restarting rails..."
  cd $app_root
  RAILS_ENV=production bin/rails restart
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