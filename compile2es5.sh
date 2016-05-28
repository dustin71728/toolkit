#!/bin/bash

RECORD_LAST_MODIFIED_PATH='/tmp/compile2es5_watch'
MD5HASHDIR=$RECORD_LAST_MODIFIED_PATH'/'$(echo $PWD | md5sum | tr -d ' -')
IS_IN_WATCHING_MODE=0

stopWatching()
{
	echo "Leave watching mode."
	rm -rf "$MD5HASHDIR"
	exit $SIGNAL_TERMINATED;
}

shopt -s extglob
parse ()
{
	ORIIFS=$IFS
	IFS=''
	comments=0
	for i in ./!(*-compiled).js
	do
		if [ $IS_IN_WATCHING_MODE -eq 1 ]
		then
			if [ -e "$MD5HASHDIR"/"$i" ]
			then
				if $(echo $(stat -c %Y "$i") | diff "$MD5HASHDIR"/"$i" - > /dev/null 2>&1)
				then
					continue
				else
					echo "$i has changed, need to recompile"
					echo $(stat -c %Y "$i") > "$MD5HASHDIR"/"$i"
				fi	 
			else
				echo "Set last modified time for $i"
				echo $(stat -c %Y "$i") > "$MD5HASHDIR"/"$i"
			fi
		fi
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
			if $( echo "$str" | grep -q '/\*' )
			then
				comments=1
				str=$( echo "$str" | sed 's/\/\*/\/\//' )
			elif [ $comments -eq 1 ]
			then
				str='//'$str
			fi
			if $( echo "$str" | grep -q '\*/' )
			then
				comments=0
				str=$( echo "$str" | sed 's/\*\///' )
			fi			
			echo ' * '"$str" >> $tmp
		done < $i
		echo -n ' * ' >> $tmp
		printf "=%.0s" {1..78} >> $tmp
		echo '*/' >> $tmp
		echo >> $tmp
		babel $i --out-file $new 
		cat $tmp $new > $dst_file
		rm $tmp
		if [ -e "$new" ]; then rm "$new"; fi
	done
	IFS=$ORIIFS	
}

if [ $# -gt 0 ]
then
	option=""
	getopts ":wbs" option
	case $option in
		w )
			self=$(basename "$0")
			log_file="$PWD"/${self%.sh}'.watchlog'
			if [ -e "$RECORD_LAST_MODIFIED_PATH" ] && [ ! -d "$RECORD_LAST_MODIFIED_PATH" ]; then unlink "$RECORD_LAST_MODIFIED_PATH"; fi
			if [ ! -d "$MD5HASHDIR" ]; then mkdir -p "$MD5HASHDIR"; fi
			if [ $? -ne 0 ]; then echo "Fail to create $MD5HASHDIR" 1>&2; exit; fi
			( $0 -b >> "$log_file" 2>&1 ) &
			echo "Enter into watching mode..." | tee $log_file
			exit 0
			;;
		b )
			echo $$ > "$MD5HASHDIR"'/pid'
			IS_IN_WATCHING_MODE=1
			trap stopWatching SIGINT SIGTERM
			while true
	 		do
	 			parse
	 			sleep 1;
			done
			;;
		s )
			if [ -e "$MD5HASHDIR"'/pid' ]
			then
				kill -15 $(cat "$MD5HASHDIR"'/pid')
			fi
			;;	
		* )
			echo "Not supported argument" 
			;;
	esac
else
	parse
fi