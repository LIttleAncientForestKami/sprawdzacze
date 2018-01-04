#!/bin/bash
# Każda migawka na majstrze powinna być czysta, tj. wykonywalna i kompilowalna. 
# Skrypt idzie wstecz migawka po migawce aż do momentu, gdy się wywali. 
# Powinien wywalić się, bo 
#   1. albo nie ma POMa (zatem nie da się zrobić mvn clean install)
#   2. albo nie ma już więcej migawek
# RDZ: ładne zakończenie, czyli obkodowanie krachów zapisanych powyżej.
# Autor: @LAFK_pl

set -e

while true; do
    mvn clean install
    git reset --hard HEAD~1
done
