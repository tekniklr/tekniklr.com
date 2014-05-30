#!/bin/bash
# restart delayed_job if Dreamhost has killed it (as it does)

# modified from http://stackoverflow.com/questions/3102500/cron-tab-to-restart-my-delayed-job-server

home=/home/tekniklr
app_root=${home}/rails.tekniklr.com/current/

source ${home}/.bash_profile

if ! [ -s ${app_root}/tmp/pids/delayed_job.pid ]; then
  RAILS_ENV=production ${app_root}/script/delayed_job start
fi