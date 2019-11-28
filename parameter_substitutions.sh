#! /bin/bash

LOGFILE="${0%.sh}".log
echo $LOGFILE


# The below expression is to rename .txt files to .py files in current location.
find $PWD -type f -name '*.txt' | grep -v .do-not-touch | while read fname
do
	echo mv $fname ${fname/.txt/.py}
	mv $fname ${fname/.txt/.py}
done
