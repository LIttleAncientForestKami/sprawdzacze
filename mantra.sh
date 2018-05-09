#!/bin/bash

trace() { echo "$(tput setaf 4)$0 trace: $*$(tput sgr0)" >&2; }
ok() { echo "$(tput bold)OK!$(tput setab 2) $(tput setaf 7)$0: $*$(tput sgr0)" >&2; }
warn() { echo "$(tput setaf 3)$0: $*$(tput sgr0)" >&2; }
yell() { echo "$(tput setab 7)$(tput setaf 1)$(tput bold)$0: $*$(tput sgr0)" >&2; }
die() { yell "Dying (111): $*"; exit 111; }
try() { "$@" || die "cannot $*"; }

WYNIK=0
RAPORT=""

function punkty {
    trace "- przekazano `$1`"
    WYNIK=$((WYNIK + $1))
    trace "wynik = $WYNIK"
}
function opis {
    RAPORT="$RAPORT $1"
    trace "raport: $RAPORT"
}

function znajdź {
    find . -iname "$1"
}

function kwit_nieszablonowy {
    yell "Kwit $1 za $2"
    nieszablonowy_kwit "$1" "$2"
}

function kwit_za {
    [[ $# == 2 ]] && kwit_nieszablonowy "$@" && return
    yell "Kwit na $1"
    kwit "$1"
}

function czy_kwit_za {
    read -e -p "Wystawić kwit za $1? t/n, ENTER dla " -i "t" KWIT
    if [[ ${KWIT^^} == 'T' ]] || [[ ${KWIT^^} == 'TAK' ]]; then
        shift
        kwit_za "$2"
        punkty "$3"
        opis "$1"
    fi
}

function pom {
    grep "$1" pom.xml
}

function maven_o_projekcie {
    trace "URL, name, desc, coordinates within 20 lines of pom:"
    head -20 pom.xml | egrep "name|description|url|groupId|artifactId|version"
    czy_kwit_za "podstawy Mavena" Maven_basics.json -5
}

function mavena_czas {
    trace UTF8
    if [[ -z $(pom sourceEncoding) ]] || [[ -z $(pom outputEncoding) ]]; then
        kwit_za UTF8missing.json
        opis "Kodowanie nieustawione w pełni lub kompletnie zależne od platformy"
        punkty -1
    else
        kwit_za "UTF-8-ready POM" "hopefully you understand potential issues and why this helps! I may ask you about it later..."
        punkty 2
        opis "UTF-8 ustawiony"
    fi
    trace kompilator
    if [[ -z $(pom "maven.compiler") ]]; then
        kwit_za compilerNotSet.json
        punkty -3
        opis "Kompilator najlepiej ustawić w <properties>"
    fi
    mvn test > log
    if (( $? > 1 )); then
        kwit_za MavenLaunchFailed.json
        punkty -5
        opis "**NIE UDAŁO SIĘ ODPALIĆ**"
        rm log
        die "Maven się nie odpala!"
    fi
    warn Ostrzeżenia itp.
    grep WARNING log
    grep ERROR log
    rm log
    maven_o_projekcie
    czy_kwit_za "ładny POM!" nicePOM.json 3
}

function sprawdź_instrukcje_wykonania {
    trace Sprawdzam readme, powinny zostać wypisane paragrafy jakie mogą mieć instrukcje odpalenia:
    README=$(znajdź readme.md)
    grep -iE 'run|launch|uruchom|odpal|wykon' "$README"
    czy_kwit_za "brak instrukcji odpalenia" howToRun.json -2 || return
}

KAT=$(basename $(pwd))
trace "$KAT"
# case insensitive search
if [[ "x$(znajdź readme.md)x" == "xx" ]]; then
    kwit_za noReadme.json
    punkty -3
    opis "Brak opisu repo, zwykle jest w readme.md"
else
    punkty 1
    opis "Repo opisane - dobra robota!"
    sprawdź_instrukcje_wykonania
fi
echo "=================================================="
MIGAWEK="$(git log --oneline | wc -l)"
ok "Migawek: $MIGAWEK"
opis "`$MIGAWEK` Migawek"
git shortlog -n
czy_kwit_za "Kiepską ilosć / jakość migawek?" gitShouldTellAStory.json -4
czy_kwit_za "Dobre migawki" gitNiceStory.json 4
if [[ -f .gitignore ]]; then
    punkty 1
    opis "jest .gitignore."
    trace Ignorowane obecnie są:
    git ignored
    trace .gitignore zawiera:
    cat .gitignore
    ok czy są śmieci w repo?
    trace git ls-files:
    git ls-files | grep -e 'class|target|iml|jar'
    czy_kwit_za "śmieci w repo" "Trash in repo despite .gitignore" "Use \`git-ls-files\` and \`cat .gitignore\` and compare. Stop tracking, commit, push." -1
    czy_kwit_za "brak śmieci w repo" "Well done with .gitignore" "No trash in repo found" 1
else
    kwit_za gitignore.json
    punkty -2
    opis "brak pliku .gitignore, śmieci w repo."
fi
if [[ -f .gitattributes ]]; then
    trace ATRYBUTY GITA
    punkty 1
    opis "Atrybuty Gita są\!"
    cat .gitattributes
else
    kwit_za gitattr.json -1
fi
if [[ -f .mailmap ]]; then
    trace Mapa maili autorów
    punkty 1
    opis "Mapa mejli jest."
    cat .mailmap
else
    kwit_za gitmailmap.json
    punkty -1
    opis "Nie ma mapy mejli."
fi
echo "=================================================="
if [[ ! -f pom.xml ]]; then
    kwit_za "Mavenize this project" "pretty please"
    punkty -5
    opis "projekt nie jest Mavenowy nawet\!"
else
    punkty 5
    opis "Projekt pod Mavenem."
    mavena_czas
fi
echo "$WYNIK"
kwit_za "Mantra w sumie" "$RAPORT. Razem: $WYNIK"
