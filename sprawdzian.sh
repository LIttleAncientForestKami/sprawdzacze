#!/bin/bash

function porażka() {
    echo "# tag::powód[]" > porażka.adoc
    echo "Porażka! $1" >> porażka.adoc
    echo "# end::powód[]" >> porażka.adoc
}

for f in *_NAZWA_TUTAJ; do
    echo $f
    cp raport.adoc $f
    cd $f
    porażka "Twój program na szczęście nie poniósł takowej."
    git shortlog -sn > shortlog.txt
    if [[ -f .gitignore ]]; then
        echo "Jest .gitignore" > gi.txt
        echo "Śmieci w repo?" >> gi.txt
        git ls-files | grep -e 'class\target\iml\jar' >> gi.txt
        echo "Jeśli pomiędzy pytaniem a tą linią nic nie ma... to nie ma" >> gi.txt
    else 
        echo "Brak .gitignore - zdecydowanie oznaka złej higieny projektu i słabych umiejętności autorki/a" > gi.txt 
    fi
    if [[ -f pom.xml ]]; then
        echo Jest POM
    else 
        porażka "Brak Mavena, nie mam POMa, nie mogę przeprowadzić audytu."
        cd ..
        continue
    fi
    echo mvnci
    mvn clean install | egrep Compiling\|resourceDirectory\|Building\|Installing\|"Time elapsed:"\|WARNING\|ERROR\|BUILD\|Total > mvn.log
    if [[ "$?" > 0 ]]; then
        porażka "podczas budowy wystąpiły błędy. Spójrz na zapis z budowy."
        cd ..
        continue
    fi
    echo Mapa pakietów
    BAZA=$(ls src/main/java)
    jdeps -apionly -R -e "$BAZA"'.*' -dotoutput . target/*.jar
    for d in *.dot; do
        if [[ "$d" = "summary.dot" ]]; then
            continue
        fi
        sfdp -Grotate=90 -Tpng $d -o sfdp-mp.png
        osage -Tpng $d -o osage-mp.png
    done
    echo Mapa klas
    jdeps -apionly -verbose:class -R -e "$BAZA"'.*' -dotoutput . target/*.jar
    for d in *.dot; do
        if [[ "$d" = "summary.dot" ]]; then
            continue
        fi
        sfdp -Grotate=90 -Tpng $d -o sfdp-mc.png
        osage -Tpng $d -o osage-mc.png
    done
    cd src/main/java
    find . -iname *.java > ../../../klasy.log
    cd -
    asciidoctor-pdf raport.adoc
    cd ..
done
