#!/bin/bash

total=0
idle=0
system=0
user=0
#nice=0
#mem=0
vmexec=/usr/bin/vmstat
which sar > /dev/null 2>&1
if [ $? -ne 0 ]
then
  ver=`vmstat -V | awk '{printf $3}'`
  nice=0
  temp=`vmstat 1 3 |tail -1`
  user=`echo $temp |awk '{printf("%s\n",$13)}'`
  system=`echo $temp |awk '{printf("%s\n",$14)}'`
  idle=`echo $temp |awk '{printf("%s\n",$15)}'`
  total=`echo|awk '{print (c1+c2)}' c1=$system c2=$user`
fi
#echo "#CPU Utilization#"
#echo "Total CPU  is already use: $total"
#echo "CPU user   is already use: $user"
#echo "CPU system is already use: $system"
#echo "CPU nice   is already use: $nice"
#echo "CPU idle   is already use: $idle"

echo $user

