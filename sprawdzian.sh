#!/bin/bash
# exit 1 - cd zawiodło
# exit 2 - podano zły parametr nazwa lub go nie podano
# exit 3 - audyt zakończony porażką: nie powiodły się potrzebne sprawdzenia i kończymy raportowanie

# błędy kompilacji i nie przechodzące testy == porażka
# ostrzeżenia - tylko ujemne punkty
# raport z błędami w obu wypadkach
# TODO: przerobić na skrypt działający na jednym katalogu
# sprzątanie po sobie?

# pliki tymczasowe nazywają się
PREFIX="spr"
EXT="tmplog"
GIG="$PREFIX"_gi."$EXT"
GIS="$PREFIX"_giShortLog."$EXT"
GIL="$PREFIX"_giLog."$EXT"
MVN="$PREFIX"_mvn."$EXT"
KLA="$PREFIX"_klasy."$EXT"
set -x

function notka() { echo "$(tput setaf 4)$0: $*$(tput sgr0)" >&2; }
function uwaga() { echo "$(tput setab 7)$(tput setaf 1)$(tput bold)$0: $*$(tput sgr0)" >&2; }

function brak_nazwy_wychodzę() {
    if [[ "" = "$NAZWA" ]]; then
        uwaga "Niezbędny parametr do działania to katalog np: Jan_OX"
        exit 2
    else
        notka "Sprawdzam istnienie $NAZWA"
    fi
    if [[ ! -d "$NAZWA" ]]; then
        uwaga "Nie ma katalogu $NAZWA"
        exit 2
    fi
}

function porażka() {
    sed -i "s/:a: ATRYBUTY_TUTAJ/:porażka: $1/" $RAPORT
    asciidoctor-pdf $RAPORT
    exit 3
}

function jest_pom() {
    if [[ -f pom.xml ]]; then
        notka Jest POM
    else 
        porażka "Brak Mavena, nie mam POMa, nie mogę przeprowadzić audytu."
    fi
}

function spr_gi() {
    echo "Jest .gitignore"
    echo "Śmieci w repo?"
    git ls-files | grep -e 'class\target\iml\jar'
    echo "Jeśli pomiędzy pytaniem a tą linią nic nie ma... to nie ma"
}

function budujemy() {
    notka mvnci, bez logów, także tych z testów
    mvn -l $MVN clean install -Dmaven.test.redirectTestOutputToFile=true
    if [[ "$?" -gt 0 ]]; then
        uwaga """.Błędy kompilacji:
        ----
        $(cat $MVN)
        ----
        """
        porażka "podczas budowy wystąpiły błędy. Spójrz na zapis z budowy."
    fi
}


NAZWA=$1
brak_nazwy_wychodzę

notka "Zaczynam pracę nad $NAZWA"

RAPORT="$PREFIX"_$(basename $NAZWA)_raport.adoc
cp "$(dirname "$0")"/raport.adoc "$NAZWA"/"$RAPORT"
cd "$NAZWA" || exit 1
sed -i "s/NAZWA_TUTAJ/$(basename $NAZWA)/" $RAPORT

jest_pom

budujemy

notka "Zobaczmy kto nad tym pracował?"
git shortlog -sn > $GIS

notka "Ignorowane pliki Gita"
if [[ -f .gitignore ]]; then
    spr_gi > $GIG
else 
    echo "Brak .gitignore - zdecydowanie oznaka złej higieny projektu" > $GIG
fi
#echo Mapa pakietów
#BAZA=$(ls src/main/java)
#jdeps -apionly -R -e "$BAZA"'.*' -dotoutput . target/*.jar
#for d in *.dot; do
#    if [[ "$d" = "summary.dot" ]]; then
#        exit 3
#    fi
#    sfdp -Grotate=90 -Tpng "$d" -o sfdp-mp.png
#    osage -Tpng "$d" -o osage-mp.png
#done
#echo Mapa klas
#jdeps -apionly -verbose:class -R -e "$BAZA"'.*' -dotoutput . target/*.jar
#for d in *.dot; do
#    if [[ "$d" = "summary.dot" ]]; then
#        exit 3
#    fi
#    sfdp -Grotate=90 -Tpng "$d" -o sfdp-mc.png
#    osage -Tpng "$d" -o osage-mc.png
#done
#cd src/main/java || exit 1
notka Ile klas tu mamy?
find src/main/java -iname "*.java" > $KLA #../../../klasy.log
notka "Raport do PDFa i sprzątanie"
asciidoctor-pdf $RAPORT -o raport.pdf
#rm spr_*
notka Koniec pracy
mupdf raport.pdf
cd - || exit 1
