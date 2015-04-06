
#!/bin/bash
n=365
#tar -cjf "backup/$(date +%Y-%m-%d-%H%M).tar.bz2"  kalender.ics html/*
rm  html/* eindaten wdhdaten
sed -i '/DTSTART;VALUE/{ N; s/DTSTART;\(.*\)\nDTEND;.*/DTSTART;\1\nDTEND;\1/ }' kalender.ics #alle mehrtägigen zu eintägigen
for ((i=0;i<=$n;i++));
do
	datum=$(date --date="$i day" +%Y%m%d)
	if [ -e $datum.ics ];
	then
		echo $datum >> eindaten
	else
		echo $datum >> wdhdaten
	fi;
done
while [ $(for ((i=0;i<=$n;i++));
	do
		if [ -e html/$(date --date="$i day" +%Y%m%d).html ];
		then
			echo "ok";
		else
			echo "not ok";
		fi;
	done | grep not | wc -l) -gt  0 ];
do
	echo "work to do"
#	echo : > computers
#	for i in $(nmap -sP 192.168.67.21-31 | grep 192.168.67. | sed 's!.*\(192.168.67.*\)!\1!');
#	do
#		echo foo@$i >> computers
#		scp wdhtermine.ics 20*.ics foo@$i:~/;ssh foo@$i "if [ -d html ]; then rm html/*;else mkdir html;fi"
#	done;
#	if [ ! $(diff wdhtermine.ics altwdhtermine.ics|wc -l) == 0 ];
#	then
	for i in $(cat wdhdaten);
	do
		if [ ! -f html/$i.html ];
		then
			echo $i;
		fi;
	done | parallel   --progress --return html/{}.html --sshloginfile computers '/usr/share/doc/libical-parser-html-perl/examples/ical2html -d {} wdhtermine.ics 2> /dev/null | grep -E "all-day |p.*summary|<p.*location|<p.*description|event-time|20[0-9]{2}</h1>" > html/{}.html'
#	fi
	for i in $(cat eindaten);
	do
#		if [ ! $(diff $i.ics alt$i.ics|wc -l)==0 ];
#		then
		if [ ! -f html/$i.html ];
		then
			echo $i;
		fi;
#		fi;
	done |  parallel --progress --return html/{}.html --sshloginfile computers '/usr/share/doc/libical-parser-html-perl/examples/ical2html -d {} {}.ics 2> /dev/null | grep -E "all-day |p.*summary|<p.*location|<p.*description|event-time|20[0-9]{2}</h1>" > html/{}.html'
done
