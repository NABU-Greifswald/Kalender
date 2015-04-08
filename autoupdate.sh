#!/bin/bash
# Arbeitsverzeichnis für alles weitere definieren
workdir=~/Dokumente/Nabukram/kalender-working-dir
#echo $(date) #wozu? nur als Lebenszeichen?
function splitinput {
cd $workdir
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
}
function ics2html {
#!/bin/bash
n=10
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
}
function html2tex {
texdata=$workdir/data.tex
if [ -e $texdata ]; then
	rm $texdata
fi
# werden hier  einfach nur leere Tage gelöscht?
for i in html/*;do
  if [ $(stat -c %s $i) -lt 50 ]; then
    rm $i;
  fi;
done
for i in $(for l in {0..1};do  date --date="$l year" +%Y;done);do
#   monate=$(ls html/$i* 2> /dev/null | wc -l)
#   if [ $monate != 0 ]; then
#     echo "\jahr{$i}" >> $texdata;
#   fi
  for j in {01..12};do
    relmon=$((10#$j-(10#$(date +%m)))); #Nummer des Monats relativ zum aktuellen Monat
    tage=$(ls html/$i$j* 2> /dev/null | wc -l) # ist an irgendeinem Tag
    if [ $tage != 0 ]; then
      echo "\monat{$(date --date="$relmon month" +%B) $i}" >> $texdata;
    fi;
    for k in {01..31};do
      if [ -f html/$i$j$k.html ]; then
	echo "$i$j$k";
	cat html/$i$j$k.html |
	sed -e 's!Monday!Mo!g' -e 's!Tuesday!Di!g' -e 's!Wednesday!Mi!g' -e 's!Thursday!Do!g' -e 's!Friday!Fr!g' -e 's!Saturday!Sa!g' -e 's!Sunday!So!g' |
	sed 's![ ]*<h1>\(.\{2\}\).* \([0-9]\{1,2\}\), 20[0-9]\{2\}</h1>!\\datum{\1}{\2}{!g' |
	sed ':a;N;$!ba;s!-\n[ ]*\|</p>\n[ ]*<p!!g' |
	sed ':a;N;$!ba;s!\\datum{[0-9]\{1,2\}}{\n\\!\\!g' |
	sed 's![ ]*<div class="event-time calendar-1">\([0-9]\{1,2\}\):\([0-9]\{1,2\}\) <p class="summary">\(.*\) class="location">(\([^)]\+\))* class="description">\(.*\)HINWEIS: \(.*\)</p>!\t\\termin{NABU}{\1:\2}{\3}{\4}{\\\\\\footnotesize{\6}}!g' |
	sed 's![ ]*<div class="event-time calendar-1">\([0-9]\{1,2\}\):\([0-9]\{1,2\}\) <p class="summary">\(.*\) class="location">()* class="description">\(.*\)HINWEIS: \(.*\)</p>!\t\\termin{NABU}{\1:\2}{\3}{$\\approx$}{\\\\\\footnotesize{\5}}!g' |
	sed 's![ ]*<div class="event-time calendar-1">\([0-9]\{1,2\}\):\([0-9]\{1,2\}\) <p class="summary">\(.*\) class="location">(\([^)]\+\))* class="description">\(.*\)</p>!\t\\termin{NABU}{\1:\2}{\3}{\4}{}!g' |
	sed 's![ ]*<div class="event-time calendar-1">\([0-9]\{1,2\}\):\([0-9]\{1,2\}\) <p class="summary">\(.*\) class="location">()* class="description">\(.*\)</p>!\t\\termin{NABU}{\1:\2}{\3}{$\\approx$}{}!g' |
	sed 's![ ]*<td class="all-day calendar-1" colspan="1">\(.*\)</td>!\t\\termin{NABU}{\\clock}{\1}{$\\approx$}{}!g' |
	sed 's!\\termin{NABU}\(.*\(Orni\|[Vv][oö]gel\).*\)!\\termin{FG-Ornithologie}\1!g' |
	sed 's!\\termin{NABU}\(.*\(Stadtöko\|Saatgut-Tauschbörse\).*\)!\\termin{FG-Stadtoekologie}\1!g' |
	sed 's!\\termin{NABU}\(.*Flederm.*\)!\\termin{FG-Fledermausschutz}\1!g' |
	sed 's!\\termin{NABU}\(.*\([Ff]amilie\|Naturschwärmer\).*\)!\\termin{FG-Naturschwaermer}\1!g' |
	sed 's!\\termin{NABU}\(.*\(Mähen\|Baumschnitt\|[Oo]bst\).*\)!\\termin{FG-Streuobst}\1!g' |
	sed 's!\\termin{NABU}\(.*Entomo.*\)!\\termin{FG-Entomologie}\1!g' |
	sed 's!\\termin{NABU}\(.*\(ADFC\|Fahrrad\).*\)!\\termin{ADFC}\1!g' |
	sed 's!\\termin{NABU}\(.*\(Brozio\|S.[ ]*Starke\|Rilke\).*\)!\\termin{FG-Geobotanik}\1!g' |
	sed 's!\\termin{NABU}\(.*\(Pilz\|Amelang\).*\)!\\termin{FG-Mykologie}\1!g' |
	sed 's!\\termin{NABU}\(.*\([hH]erpet\|[aA]mphi\|[sS]chlange\).*\)!\\termin{FG-Feldherpetologie}\1!g' |
	sed 's!\\termin{NABU}\(.*\(Wald\).*\)!\\termin{FG-Wald}\1!g' |
	sed 's!&quot;\(.*\)&quot;!\\textit{\1}!g'|
	sed 's!„\(.*\)“!\\textit{\1}!g'|
	sed ':a;N;$!ba;s!\n\([^\t]\)!}\n\1!g' |
	sed ':a;N;$!ba;s!\\datum{.\{2\}}{[0-9]\{1,2\}}{}\n!!g' >> $texdata;
	echo } >> $texdata;
      fi;
    done;
  done;
done;
sed -i ':a;N;$!ba;s!}\n}!}}!g' $texdata
}
function finalstep {
xelatex -interaction nonstopmode A3-1.tex
xelatex -interaction nonstopmode A4-1.tex
for i in {2..3};
        do
                pdflatex -interaction nonstopmode A3-$i.tex
        done;
pdflatex -interaction nonstopmode A4-2.tex
timestamp=$(date +%Y-%m-%d-%H-%M)
cp A3-3.pdf /home/nabu/Kalender/Veranstaltungskalender-A3-$timestamp.pdf
cp A4-2.pdf /home/nabu/Kalender/Veranstaltungskalender-A4-$timestamp.pdf
ln -sf /home/nabu/Kalender/Veranstaltungskalender-A3-$timestamp.pdf  /home/nabu/Kalender/Veranstaltungskalender-A3-aktuell.pdf
ln -sf /home/nabu/Kalender/Veranstaltungskalender-A4-$timestamp.pdf  /home/nabu/Kalender/Veranstaltungskalender-A4-aktuell.pdf
rm A[34]-?.[^tp]*
}
#fange nur an zu arbeiten, wenn gerade keine Kalenderberechnung stattfindet, denn dies dauert idR sehr lang.
if [ $(pgrep ical2html|wc -l) == "0" ];
then
	#falls $workdir nicht existiert, lege es an.
	if [ ! -e $workidr ]
	then
		mkdir -p $workdir
	fi
	cd $workdir
	#den zuletzt geladenen googlekalender unter kalenderalt.ics abspeichern
	mv kalender.ics kalenderalt.ics #aber wozu?
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
		splitinput()
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
