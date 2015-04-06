#!/bin/bash
#ausgabe des letztens Laufes umbennen.
#könnte man sie nicht in eine anderes Verzeichnis verschieben? Entrümpeln und so?
#for i in {20*.ics,wdhtermine.ics};
#do
#	mv $i alt$i;
#done
#kalender zerschneiden
csplit -s kalender.ics /BEGIN:VEVENT/ {*}
#headerdatei umbenennen
mv xx00 header
#tail entfernen
for i in xx*;
do
	sed -i 's!END:VCALENDAR!!g' $i
	if [ $(grep RRULE $i| wc -l) == 1 ];
	then
		cat $i >> wdhtermine && rm $i
	fi;
done
for i in xx*;
	do
		dateiname=$(grep DTSTART $i | sed 's!.*\([0-9]\{8\}\).*!\1!g')
		cat $i >> $dateiname && rm $i; # warum nicht einfach mv $i $dateiname?
	done
for i in 20*;
	do
		cat wdhtermine >> $i;
	done
for i in {20*,wdhtermine};
do
	cat header >> $i.ics
	cat $i >> $i.ics
	echo "END:VCALENDAR" >> $i.ics
	rm $i;
done
