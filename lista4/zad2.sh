#!/bin/bash

loops=0

last_received=$(cat /proc/net/dev | grep 'enp0s3' | awk '{print $2}')
last_transmitted=$(cat /proc/net/dev | grep 'enp0s3' | awk '{print $10}')
last10_received=(0 0 0 0 0 0 0 0 0 0)
last10_transmitted=(0 0 0 0 0 0 0 0 0 0)
max_received=0
max_transmitted=0
avg_received=0
avg_transmitted=0

while true; do
	sleep 1

	#CALCULATING EVERYTHING

	#Internet speed connection
	received=$(cat /proc/net/dev | grep 'enp0s3' | awk '{print $2}')
	transmitted=$(cat /proc/net/dev | grep 'enp0s3' | awk '{print $10}')
	echo "$received $last_received"
	dr=$(( received - last_received ))
	dt=$(( transmitted - last_transmitted ))
	avg_received=$(echo "scale=0; (($avg_received * $loops) + $dr) / ($loops + 1)" | bc -l)
	avg_transmitted=$(echo "scale=0; (($avg_transmitted * $loops) + $dt) / ($loops + 1)" | bc -l)
	last_received=$received
	last_transmitted=$transmitted

	for i in {9..1}; do
		last10_received[i]=${last10_received[i-1]}
		last10_transmitted[i]=${last10_transmitted[i-1]};
	done;
	last10_received[0]=$dr;
	last10_transmitted[0]=$dt;

	if [[ ! " ${last10_received[*]} " =~ " ${max_received} " ]]; then
    	max_received=0
	fi
	if [[ ! " ${last10_transmitted[*]} " =~ " ${max_transmitted} " ]]; then
    	max_transmitted=0
	fi
	for i in {0..9}; do
		if [[ "$max_received" -lt "${last10_received[i]}" ]]; then
			max_received=${last10_received[i]}
		fi
		if [[ "$max_transmitted" -lt "${last10_transmitted[i]}" ]]; then
			max_transmitted=${last10_transmitted[i]}
		fi
	done

	if [[ $dr -lt 1024 ]]; then
		dr=$(echo "$dr B/s")
	elif [[ $dr -lt 1048576 ]]; then
		dr=$(echo "scale=2; $dr / 1024" | bc -l)
		dr=$(echo "$dr kB/s")
	else
		dr=$(echo "scale=2; $dr / 1048576" | bc -l)
		dr=$(echo "$dr MB/s")
	fi

	if [[ $dt -lt 1024 ]]; then
		dt="$dt B/s"
	elif [[ $dt -lt 1048576 ]]; then
		dt=$(echo "scale=2; $dt / 1024" | bc -l)
		dt="$dt kB/s"
	else
		dt=$(echo "scale=2; $dt / 1048576" | bc -l)
		dt="$dt MB/s"
	fi

	avg_received_2show=""
	if [[ $avg_received -lt 1024 ]]; then
		avg_received_2show=$(echo "$avg_received B/s")
	elif [[ $avg_received -lt 1048576 ]]; then
		avg_received_2show=$(echo "scale=2; $avg_received / 1024" | bc -l)
		avg_received_2show=$(echo "$avg_received_2show kB/s")
	else
		avg_received_2show=$(echo "scale=2; $avg_received / 1048576" | bc -l)
		avg_received_2show=$(echo "$avg_received_2show MB/s")
	fi

	avg_transmitted_2show=""
	if [[ $avg_transmitted -lt 1024 ]]; then
		avg_transmitted_2show=$(echo "$avg_transmitted B/s")
	elif [[ $avg_transmitted -lt 1048576 ]]; then
		avg_transmitted_2show=$(echo "scale=2; $avg_transmitted / 1024" | bc -l)
		avg_transmitted_2show=$(echo "$avg_transmitted_2show kB/s")
	else
		avg_transmitted_2show=$(echo "scale=2; $avg_transmitted / 1048576" | bc -l)
		avg_transmitted_2show=$(echo "$avg_transmitted_2show MB/s")
	fi

	#System working time
	total_time=$(cat /proc/uptime | awk -F '.' '{print $1}')
	days=$(( total_time / 86400 ))
	total_time=$(( total_time - $(( days * 86400 )) ))
	hours=$(( total_time / 3600 ))
	total_time=$(( total_time - $(( hours * 3600 )) ))
	mins=$(( total_time / 60 ))
	total_time=$(( total_time - $(( mins * 60 )) ))
	seconds=$total_time

	#Battery percentage
	battery=$(cat /sys/class/power_supply/BAT0/uevent | grep "^POWER_SUPPLY_CAPACITY=" | awk -F '=' '{print $2}')

	#clear
	tput cup 0 0

	#SHOWING TO THE SCREEN AND CALCULATING

	echo "RECEIVING SPEED: $dr"
	echo "TRANSIMIITING SPEED: $dt"
	echo "AVERAGE RECEIVING SPEED: $avg_received_2show"
	echo "AVERAGE TRANSIMIITING SPEED: $avg_transmitted_2show"

	echo ""

	#Draw plots for speed connection
	echo "RECEIVING SPEED"
	(echo " ;0;$max_received B/s"
	for i in {0..9}; do
		hash_block=""
		hash_num=0
		if [[ $max_received -gt 0 ]]; then
			hash_num=$(echo "scale=0; ${last10_received[i]} * 20 / $max_received" | bc -l)
			if [[ hash_num -eq 0 ]] && [[ ${last10_received[i]} -gt 0 ]]; then
				hash_num=1
			fi
		fi
		for (( j=1; j<=20; j++ )); do
			if [[ $j -le $hash_num ]]; then
				hash_block=$(echo "${hash_block}#")
			else
				hash_block=$(echo "${hash_block} ")
			fi
		done
		echo "${i}sec ago;[$hash_block;];${last10_received[i]} B/s"
	done ) | column -t -s ';'

	echo ""

	echo "TRANSMITTING SPEED"
	(echo " ;0;$max_transmitted B/s"
	for i in {0..9}; do
		hash_block=""
		hash_num=0
		if [[ $max_transmitted -gt 0 ]]; then
			hash_num=$(echo "scale=0; ${last10_transmitted[i]} * 20 / $max_transmitted" | bc -l)
			if [[ hash_num -eq 0 ]] && [[ ${last10_transmitted[i]} -gt 0 ]]; then
				hash_num=1
			fi
		fi
		for (( j=1; j<=20; j++ )); do
			if [[ $j -le $hash_num ]]; then
				hash_block=$(echo "${hash_block}#")
			else
				hash_block=$(echo "${hash_block} ")
			fi
		done
		echo "${i}sec ago;[$hash_block;];${last10_transmitted[i]} B/s"
	done ) | column -t -s ';'

	echo ""

	#CPU's usage
	echo "CPU'S USAGE:"
	(echo "Core number|Core usage|Core speed"
	cat /proc/cpuinfo | grep "^processor" | while read cpu_nr
	do
		cpu_nr=$(echo $cpu_nr | awk -F ': ' '{print $2}')

		cpu_usage=$(grep "cpu${cpu_nr}" /proc/stat | awk '{usage=($2+$3+$4)*100/($2+$3+$4+$5)} END {print usage}')

		cpu_speed=$(cat /proc/cpuinfo | grep "MHz" | sed -n $(( cpu_nr + 1 ))p | awk -F ':' '{print $2}')
		echo "$cpu_nr|$cpu_usage%|$cpu_speed MHz"
	done) | column -t -s "|"

	echo ""

	echo "SYSTEM WORKING TIME: $days days, $hours hours, $mins minutes, $seconds seconds"

	echo ""

	echo "BATTERY PERCENTAGE: $battery%"

	echo ""

	#Memory usage
	total_memory=$(cat /proc/meminfo | grep '^MemTotal:' | awk '{print $2, $3}')
	free_memory=$(cat /proc/meminfo | grep '^MemFree:' | awk '{print $2, $3}')
	available_memory=$(cat /proc/meminfo | grep '^MemAvailable:' | awk '{print $2, $3}')
	echo "MEMORY USAGE:"
	echo "Total memory: $total_memory"
	echo "Free memory: $free_memory"
	echo "Available memory: $available_memory"
	total_memory=$(echo $total_memory | awk '{print $1}')
	free_memory=$(echo $free_memory | awk '{print $1}')
	part_of_used_mem=$(echo "($total_memory-$free_memory)/$total_memory*100" | bc -l | awk -F '.' '{print $1}')
	echo "Part of used memory: $part_of_used_mem%"

	loops=$(( loops + 1 ))

done

