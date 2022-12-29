#!/bin/bash

declare -A files
declare -A equal_files

file_names=$(find $1 -type f)
for f in $file_names
do
	files[$f]=$(sha256sum $f | awk '{print $1}')
done

for f1 in "${!files[@]}"
do
	for f2 in "${!files[@]}"
	do

		if [[ $f1 != $f2 ]] && [[ ${files[$f1]} == ${files[$f2]} ]]
		then
			if cmp --silent $f1 $f2
			then
				equal_files["$f1|$f2"]=$(ls -l $f1 | awk '{print $5}')
			fi
		fi

	done
	unset 'files[$f1]'
done

if [[ 0 == "${#equal_files[@]}" ]]; then
	echo "No identical files"
	exit
fi

(echo "file1|file2|size"

for k in "${!equal_files[@]}"
do
	echo "${equal_files[$k]} ${k}"
done | sort -rn | while read size f1f2; do
	echo "${f1f2}|${size}"
done) | column -t -s "|" 

