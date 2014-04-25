#!/bin/bash
# restart delayed_job if Dreamhost has killed it (as it does)

# from http://stackoverflow.com/questions/3102500/cron-tab-to-restart-my-delayed-job-server

app_root=/home/tekniklr/rails.tekniklr.com/current/

if ! [ -s ${app_root}/tmp/pids/delayed_job.pid ]; then
  RAILS_ENV=production ${app_root}/script/delayed_job start
fi