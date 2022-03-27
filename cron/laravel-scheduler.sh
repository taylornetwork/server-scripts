#!/usr/bin/env bash

# The only real reason to use this is so that you can log the output
# of the schedules in case of errors and the only reason to have this 
# file is so that you actually get the dates and time listed to make 
# it slightly more legible.

# Add this to the cron jobs
# * * * * * bash /home/[username]/server-scripts/cron/laravel-scheduler.sh

# Set the username
USERNAME=username

DATE=$(date +\%Y-\%m-\%d)
TIME=$(date +\%H:\%M:\%S)

# Set the paths
LOG_FILE=/home/$USERNAME/logs/laravel-scheduler/schedule_$DATE.log
APP_PATH=/home/$USERNAME/project/current

echo [$DATE - $TIME]: >> $LOG_FILE
php $APP_PATH/artisan schedule:run >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE


