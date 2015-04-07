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
git.sh
