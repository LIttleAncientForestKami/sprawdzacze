#!/bin/bash
# exit 1 - cd zawiodło
# exit 2 - podano zły parametr nazwa lub go nie podano

NAZWA=$1

function porażka() {
    echo "# tag::powód[]" > porażka.adoc
    echo "Porażka! $1" >> porażka.adoc
    echo "# end::powód[]" >> porażka.adoc
}

function spr_gi() {
    echo "Jest .gitignore"
    echo "Śmieci w repo?"
    git ls-files | grep -e 'class\target\iml\jar'
    echo "Jeśli pomiędzy pytaniem a tą linią nic nie ma... to nie ma"
}

function brak_nazwy_wychodzę() {
    if [[ "" = "$NAZWA" ]]; then
        echo "Niezbędny parametr do działania to katalog lub regex katalogowy, np: Jan_OX albo *_OX"
        exit 2
    else
        echo "Sprawdzam istnienie $NAZWA"
    fi
    if [[ ! -a "$NAZWA" ]]; then
        echo "Nie ma katalogu/ów $NAZWA"
        exit 2
    fi
}

brak_nazwy_wychodzę

for f in "$NAZWA"; do
    echo "Zaczynam pracę nad $f"
    cp "$(basename "$0")"/raport.adoc "$f"
    cd "$f" || exit 1
    porażka "Twój program na szczęście nie poniósł takowej."
    git shortlog -sn > shortlog.txt
    if [[ -f .gitignore ]]; then
        spr_gi > gi.txt
    else 
        echo "Brak .gitignore - zdecydowanie oznaka złej higieny projektu i słabych umiejętności autorki/a" > gi.txt 
    fi
    if [[ -f pom.xml ]]; then
        echo Jest POM
    else 
        porażka "Brak Mavena, nie mam POMa, nie mogę przeprowadzić audytu."
        cd .. || exit 1
        continue
    fi
    echo mvnci
    mvn clean install | grep -e Compiling\|resourceDirectory\|Building\|Installing\|"Time elapsed:"\|WARNING\|ERROR\|BUILD\|Total > mvn.log
    if [[ "$?" -gt 0 ]]; then
        porażka "podczas budowy wystąpiły błędy. Spójrz na zapis z budowy."
        cd .. || exit 1
        continue
    fi
    echo Mapa pakietów
    BAZA=$(ls src/main/java)
    jdeps -apionly -R -e "$BAZA"'.*' -dotoutput . target/*.jar
    for d in *.dot; do
        if [[ "$d" = "summary.dot" ]]; then
            continue
        fi
        sfdp -Grotate=90 -Tpng "$d" -o sfdp-mp.png
        osage -Tpng "$d" -o osage-mp.png
    done
    echo Mapa klas
    jdeps -apionly -verbose:class -R -e "$BAZA"'.*' -dotoutput . target/*.jar
    for d in *.dot; do
        if [[ "$d" = "summary.dot" ]]; then
            continue
        fi
        sfdp -Grotate=90 -Tpng "$d" -o sfdp-mc.png
        osage -Tpng "$d" -o osage-mc.png
    done
    cd src/main/java || exit 1
    find . -iname "*.java" > ../../../klasy.log
    cd - || exit 1
    asciidoctor-pdf raport.adoc
    cd .. || exit 1
done
