find $PWD -type f -name '*.txt' | grep -v .do-not-touch | while read fname
do
	echo mv $fname ${fname/.txt/.py}
	mv $fname ${fname/.txt/.py}
done
