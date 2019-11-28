#! /bin/bash

if [ "$#" -eq 0 ]
then
    echo "No arguments provided"
else
    echo "provided arguments are: $@"
    echo "provided arguments count: $#"
fi
