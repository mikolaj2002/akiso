#!/bin/bash

IFS=$'\n'

find . -maxdepth 1 -type f -print0 | while read -d $'\0' file
do
	mv "$file" "${file,,}" -n
done

