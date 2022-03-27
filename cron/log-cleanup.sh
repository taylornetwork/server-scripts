#!/usr/bin/env bash

# Add a monthly job to clean up logs so you don't accumulate a huge number of them

# I use
# 0 2 1 * * bash /home/[username]/server-scripts/cron/log-cleanup.sh

USERNAME=username
LOG_PATH=/home/$USERNAME/logs/laravel-scheduler

CURRENT_MONTH=$(date +\%m)
PREVIOUS_MONTH=$((CURRENT_MONTH-1))
YEAR=$(date +\%Y)

# When we get the previous month, it will occasionally be under 10 and need a 0 prepended.
if (( PREVIOUS_MONTH < 10 )); then
	PREVIOUS_MONTH=0$PREVIOUS_MONTH
fi

cd $LOG_PATH

for file in $(ls | grep -Ev _$YEAR-$CURRENT_MONTH | grep -Ev _$YEAR-$PREVIOUS_MONTH); do
	sudo rm $file
done