#!/bin/bash
texdata=texfiles/data.tex
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
