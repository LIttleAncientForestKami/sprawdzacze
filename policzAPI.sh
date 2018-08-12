#!/bin/bash

liczAPI() {
    # BASH
    find src/main -type f -name \*.java -exec grep -c $1 {} \; | zsumuj
    # ZSH: grep -c $1 src/main/**/*.java | awk -F ":" '{print $2}' | paste -sd+ - | bc
}

# sumuje kolumnę liczb
zsumuj() {
    paste -sd+ - | bc $1
}

liczAPIPakietowe() {
    # 1. throws tylko na metodach, zatem
    find src/main -type f -name \*.java -exec grep throws {} \; > pakietoweTymczas
    # 2. metody bez throws rozpoznamy po ") {"
    find src/main -type f -name \*.java -exec grep ") {" {} \; >> pakietoweTymczas
    tylkoMetody pakietoweTymczas | niePublicProtectedPrivate | wc -l
    rm pakietoweTymczas
}

niePublicProtectedPrivate() {
    grep -v "public\|protected\|private" $1
}

tylkoMetody() {
    grep -v "try\|catch\|finally\|if\|else\|for\|do\|while" $1
}

echo API w src/main:
echo prywatne:  $(liczAPI private)
echo chronione: $(liczAPI protected)
echo publiczne: $(liczAPI public)
echo pakietowe: $(liczAPIPakietowe)
