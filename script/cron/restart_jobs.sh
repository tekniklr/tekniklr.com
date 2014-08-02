#!/bin/bash
# restart delayed_job if Dreamhost has killed it (as it does)

# modified from http://stackoverflow.com/questions/3102500/cron-tab-to-restart-my-delayed-job-server

home=/home/tekniklr
app_root=${home}/rails.tekniklr.com/current/
pid_file=${app_root}/tmp/pids/delayed_job.pid

# load environment
source ${home}/.bash_profile > /dev/null 2>&1

# sometimes we get multiple delayed_job processes- kill any
kill_orphaned_delayed_jobs () {
  echo "Checking for orphaned delayed_job processes..."
  if pgrep -u tekniklr -f delayed_job > /dev/null 2>&1; then
    echo "Orphaned jobs found! Killing..."
    pkill -u tekniklr -f delayed_job > /dev/null 2>&1
  else
    echo "No oprhapned jobs found."
  fi
}

# function to actually restart delayed_job
restart_delayed_job () {
  kill_orphaned_delayed_jobs
  echo "Starting a new delayed_job process..."
  RAILS_ENV=production ${app_root}/script/delayed_job start
  echo "Started delayed_job!"
}

# does rails THINK delayed_job is running
if [ -s  $pid_file ]; then
  # yes - but do we actually have a process to match that pid?
  if ! ps -p `cat $pid_file` > /dev/null 2>&1
    # yes - we have a running delayed job task to match rails' view of reality
  then
    # no - restart
    rm $pid_file
    echo "Removed dangling delayed_job pid file"
    restart_delayed_job
  fi
else
  # no - restart
  echo "No delayed_job pid file"
  restart_delayed_job
fi