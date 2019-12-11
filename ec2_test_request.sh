#! /bin/bash

LOGFILE="${0%%.sh}.log"
RESULTFILE="${0%%.sh}.html"
exec >$LOGFILE
exec 2>&1
echo $LOGFILE
echo "Bash version ${BASH_VERSION}..."
declare -a IP_ADDRESSES=("IP-1" "IP-2" "IP-3")
for i in {0..250}
   do
      echo "<h4> Iteration No: $i </h4>" >> $RESULTFILE
      for ip in "${IP_ADDRESSES[@]}"
      do
          curl -s "http://${ip}:80" >> $RESULTFILE
      done
done
