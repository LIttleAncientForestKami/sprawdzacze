#!/bin/bash

git log --format="" --shortstat --no-merges | sort -n > stats
MIN=$(head -1 < stats | cut -d " " -f 2)
MAX=$(tail -1 < stats | cut -d " " -f 2)
COUNT=$(git log --oneline | wc -l)
FRACTION=$(( $COUNT/10 ))

echo Wszystkich migawek: $COUNT
echo Największa zmiana objęła plików: $MAX
echo Najmniejsza: $MIN

STAT=$(cat stats | tr -d \[:alpha:\]\(\),+-)

echo "10ta największa część: $FRACTION "
git log --no-merges --format="%h" --shortstat | grep . | awk '(NR%2>0) || (NR%2==0) && ($1 >= 15) || (NR%2==0) && ($4-100 > $6)' | grep -B 1 "files" | tr -d \(\),+- | grep . > rozległe
echo "Rozległych migawek: plików >= 15, linii różnicy >= 100: $(wc -l <rozległe)"

#cat stats | tr -d \[:alpha:\]\(\),+- | awk '($1 >= 15)'
#cat stats | tr -d \[:alpha:\]\(\),+- | awk '($2-100 >= $3)'

rm stats rozległe
