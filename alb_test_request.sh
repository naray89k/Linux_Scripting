#! /bin/bash

LOGFILE="${0%%.sh}.log"
RESULTFILE="${0%%.sh}.html"
exec >$LOGFILE
exec 2>&1
echo $LOGFILE
echo "Bash version ${BASH_VERSION}..."
URL="http://vaanu-alb-975587269.eu-west-2.elb.amazonaws.com:80"
for i in {0..250}
   do
      echo "<h4> Request No: $i </h4>" >> $RESULTFILE
      curl -s $URL >> $RESULTFILE
done
