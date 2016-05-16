#!/bin/bash
shopt -s extglob
ORIIFS=$IFS
IFS=''
for i in ./!(*-compiled).js
do
	dst_file=${i%.js}-compiled.js
	tmp='origin_code_'$$
	new='trans_code_'$$
	echo -n '/* ' >> $tmp
	printf "=%.0s" {1..80} >> $tmp
	echo >> $tmp
	echo " * The NodeJs on CodeEval doesn't support ES6, So I use babel to translate my code to ES5 standard." >> $tmp
	echo " * My original code lists as follows:"  >> $tmp
	echo " * " >> $tmp
	while read str
	do
		echo ' * '"$str" >> $tmp
	done < $i
	echo -n ' * ' >> $tmp
	printf "=%.0s" {1..78} >> $tmp
	echo '*/' >> $tmp
	echo >> $tmp
	babel $i --out-file $new 
	cat $tmp $new > $dst_file
	rm $tmp
	rm $new
done
IFS=$ORIIFS