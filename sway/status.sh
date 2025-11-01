#!/bin/bash

date=$(date +'%d-%m-%Y %I:%M:%S %p')
# bat_perc=$(cat /sys/class/power_supply/BAT0/capacity)
bat_status=$(cat /sys/class/power_supply/BAT0/status)
ssid=$(iwctl station wlan0 show | grep "Connected network" | awk '{print $3}')
# strength=$(iwctl station wlan0 show | grep "RSSI" | awk '{print $2 " " $3; exit}')
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | rg "\d+%" | awk '{print $5}')

cpu_usage=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1); }' \
    <(grep 'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat))

total_mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
available_mem_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
used_mem_kb=$((total_mem_kb - available_mem_kb))
total_mem_gb=$(echo "scale=2; $total_mem_kb / 1024 / 1024" | bc)
used_mem_gb=$(echo "scale=2; $used_mem_kb / 1024 / 1024" | bc)

# if ! [ -z "$ssid" ]; then
#     cmd+="SSID $ssid <-> STRENGTH $strength | "
# fi
cmd+=$(printf "CPU %d.2%% | " $cpu_usage)
cmd+="MEMORY $used_mem_gb GB | "
cmd+="VOLUME $volume | "
# cmd+="BATTERY $bat_perc% $bat_status | "
cmd+="DATE $date"

printf "%s " $cmd
