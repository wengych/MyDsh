#!/bin/sh
#
# $1 as file_path
# $2 as file_name
# $3 as date_mmdd

file_path=$1
file_name=$2
date_mmdd=$3

echo
echo "sshpass -p g scp out/MyDsh.swf guest@192.168.0.77:$file_path/$file_name"
sshpass -p g scp out/MyDsh.swf guest@192.168.0.77:$file_path/$file_name

echo
echo "sshpass -p g scp out/MyDsh.swf guest@192.168.0.77:MapClient/MyDsh.unstable.swf"
sshpass -p g scp out/MyDsh.swf guest@192.168.0.77:MapClient/MyDsh.unstable.swf

