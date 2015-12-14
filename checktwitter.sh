#!/bin/bash
start="1"  
step="15"  # api calls capped: max 15 calls per 15 minutes
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

# sleep for more than 15 minutes 
sleep 950 
done;

