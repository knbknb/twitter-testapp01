#!/bin/bash
start="1088"  
step="60"  # api calls capped: max 60 calls per hour 
cnt=`wc -l contacts.txt | cut -d" " -f1`
IFS=$'\n'

while [ "$start" -le "$cnt" ]; do 

 for user in `tail -n +$start contacts.txt | head -n $step `; do
 
  cmd="perl ./test-search.pl --user=\"$user\" | tee -a twitterusers.txt"
  echo $cmd
  perl ./test-search.pl --user="$user" | tee -a twitterusers.txt
  echo
  echo
 done
start=`expr $start + $step`

# sleep for more than 1 hour
sleep 3700 
done;

