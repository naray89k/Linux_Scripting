SCRIPTNAME="$(basename $0)"
for file_name in $(ls):
    do
        echo "Processing $file_name ... $SCRIPTNAME"
        if [ "$file_name" ==  "$SCRIPTNAME:" ]
        then
            echo "Skipping $SCRIPTNAME"
            continue
        else
            vim -c ":g/^#\s*$/d" -c ":g/In\[\([0-9]\|\s\+\)*\]/-d" -c ":g/In\[\([0-9]\|\s\+\)*\]/,+2d" -c "wq" $file_name
        fi
    done

