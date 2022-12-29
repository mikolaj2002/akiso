#!/bin/bash

(echo "pid|ppid|comm|state|tty|rss|pgid|sid|num_of_files"

pattern="/proc/[0-9]+"

find /proc -maxdepth 1 -type d -print0 | while read -d $'\0' pid
do

	if [[ -d $pid ]] && [[ $pid =~ $pattern ]]
	then
		num_of_files="$(($(sudo ls -l $pid/fd | wc -l)-1))"
		stat=$(cat $pid/stat)
		stat=$(echo ${stat#*)})
		process_id=$(awk '{print $1}' $pid/stat)
		comm=$(cat $pid/stat | awk -F '[()]' '{print $2}')

		echo $stat | awk -v p="$process_id" -v c="$comm" -v nf="$num_of_files" '{OFS="|"}{print p, $3, c, $1, $5, $22, $3, $4, nf}'
	fi

done) | column -t -s "|"

