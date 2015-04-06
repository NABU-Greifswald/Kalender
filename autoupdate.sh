#!/bin/bash
echo $(date)
#fange nur an zu arbeiten, wenn gerade keine Kalenderberechnung stattfindet.
if [ $(pgrep ical2html|wc -l) == "0" ];
then
	#den zuletzt geladenen googlekalender unter kalenderalt.ics abspeichern
	mv kalender.ics kalenderalt.ics
	rm wdhtermine.ics
	rm 20*ics
	#lade den aktuellen Kalender von google und speichere ihn unter kalender.ics
	wget -O kalender.ics https://www.google.com/calendar/ical/greifswald%40nabu-mv.de/public/basic.ics
	#mache aus allen mehrtägigen Terminen eintägige
	sed -i '/DTSTART;VALUE/{ N; s/DTSTART;\(.*\)\nDTEND;.*/DTSTART;\1\nDTEND;\1/ }' kalender.ics
	#alle timestamps zurücksetzen. wenn man sie löscht, meckert ical2html; also müssen sie zurück gesetzt werden, damit sie keine falsch-positiven Difftests erzeugen
	sed -i 's!DTSTAMP:.*!DTSTAMP:20130101T000001Z!g' kalender.ics 
	#TODO: falls sich nur Einzeltermine geändert haben, parse nur für diese Tage neu, nicht für 0..n
	#fange nur an zu arbeiten, falls sich seit dem letzten Download etwas im kalender geändert hat
	if [ $(diff kalenderalt.ics kalender.ics | wc -l) != 0 ];
	then 
		#die Kalender.ics aufteilen in mehrere kleine Dateien. Dies bringt einen großen Geschwindigkeitsvorteil
		./splitinput.sh
		#die .ics Dateien werden local und auf allen verfügbaren  ThinClients geparset
		./ics2html.sh
		./html2tex.sh
		./finalstep.sh
	else
		echo "Keine Veränderungen, alles bleibt beim alten.";
	fi;
else
	echo "es wird gerade ein Kalender erzeugt.";
fi
