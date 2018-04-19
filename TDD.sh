#!/bin/bash

trace() { echo "$(tput setaf 4)$0 trace: $*$(tput sgr0)" >&2; }
ok() { echo "$(tput bold)OK!$(tput setab 2) $(tput setaf 7)$0: $*$(tput sgr0)" >&2; }
warn() { echo "$(tput setaf 3)$0: $*$(tput sgr0)" >&2; }
yell() { echo "$(tput setab 7)$(tput setaf 1)$(tput bold)$0: $*$(tput sgr0)" >&2; }
die() { yell "Dying (111): $*"; exit 111; }
try() { "$@" || die "cannot $*"; }


cd ../TDD_5ed
#git clone https://github.com/Hoymm/TDD Damian_Muca_TDD
#git clone https://github.com/tomeks86/kent_beck_tdd Tomek_Seidler_TDD
#git clone https://github.com/xKoem/TDD Bartek_Kosmider_TDD
#git clone https://github.com/AdrianHarenczyk/TestDrivenDevelopment Adrian_Hareńczyk_TDD
#git clone https://github.com/totine/epam-java-academy--beck-tdd-the-money-example Joanna_Gargas_TDD
#git clone https://github.com/JaroslawSlaby/TDD_Beck Jarosław_Słaby_TDD
#git clone https://github.com/KrzysztofDzioba/tdd_beck Krzysztof_Dzioba_TDD
#git clone https://github.com/boczkas/TDD-Currency Przemysław_Jakubowski_TDD


function znajdź {
    find . -iname "$1"
}

function kwit {
    yell "Kwit na \"$1\""
    /home/tammo/rdzy/projekty/sprawdzacze/kwit.sh "$REPO" "$1"
}

function pom {
    grep "$1" pom.xml
}

function maven_o_projekcie {
    trace "URL, name, desc, coordinates:"
    head -20 pom.xml | egrep "sourceEncoding|name|description|site|url|groupId|artifactId|version"
}

function mavena_czas {
    trace UTF8
    if [[ -z $(pom sourceEncoding) ]]; then
        kwit kwity/UTF8missing.json
    fi
    trace kompilator
    if [[ -z $(pom "maven.compiler") ]]; then
        kwit kwity/compilerNotSet.json
    fi
    mvn test > log
    if (( $? > 1 )); then
        kwit kwity/MavenLaunchFailed.json
        rm log
        die "Maven się nie odpala!"
    fi
    warn Ostrzeżenia itp.
    grep WARNING log
    grep ERROR log
    rm log
    maven_o_projekcie
    ok kwit.sh "$REPO" kwity/Maven.json ALBO kwit.sh "$REPO" kwity/nicePOM.json
}

for KAT in */; do
    trace "$KAT"
    try cd "$KAT"
    if [[ "x$(znajdź readme.md)x" == "xx" ]]; then
        yell kwit kwity/noReadme.json
    fi
    echo "=================================================="
    ok Migawek: "$(git log --oneline | wc -l)"
    git shortlog -n > short.log
    URL=$(git remote show origin | grep "Fetch URL" | awk '{print $3}')
    REPO=${URL:19}
    if [[ -f .gitignore ]]; then
        trace Ignorowane obecnie są: > gi.log
        git ignored >> gi.log
        trace .gitignore zawiera: gi.log
        cat .gitignore >> gi.log
        ok czy są śmieci w repo?
        trace git ls-files: >> gi.log
        git ls-files >> gi.log
    else
        kwit kwity/gitignore.json
    fi
    if [[ -f .gitattributes ]]; then
        trace ATRYBUTY GITA
        cat .gitattributes
    else
        warn nie ma atrybutów Gita
    fi
    echo "=================================================="
    if [[ ! -f pom.xml ]]; then
        kwit "Mavenize this project" "pretty please"
    else
        mavena_czas
    fi

    cd ..
    echo -n; echo -n; echo -n
    echo "=================================================="
done
