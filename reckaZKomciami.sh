#!/bin/bash

set -e
NR=$1
. exportToken.sh
LAFK="LIttleAncientForestKami"
APPv3="Accept: application/vnd.github.full+json"

ghcurl() {
    curl -f -u "$LAFK":"$TOKEN" "$1" -H "$APPv3"
}

komcie-do-csv() {
    ghcurl "$(jq -r ._links.review_comments.href < recka"$NR".json)" > komcie"$NR".json
### Statsy główne - kto - co - kiedy - gdzie

    jq -r -c ".[] | [.user.login, .body, .created_at, .html_url] | @csv" < komcie"$NR".json > komcie"$NR".csv
    cat < komcie-linia.1wsza - komcie"$NR".csv | sponge komcie"$NR".csv
}

## Wyciągnij recki


ghcurl https://api.github.com/repos/szczepanskikrs/Battleships/pulls/"$NR" > recka"$NR".json

## Wyciągnij komcie jak jest co

IL_KOMCI=$(jq .review_comments < recka"$NR".json)
IL_UWAG=$(jq .comments < recka"$NR".json)

if [ "$IL_KOMCI" -gt 0 ]
then
    echo Recka ma komcie, ciągniemy.
    komcie-do-csv
elif [ "$IL_UWAG" -gt 0 ]
then
    echo Komcie są nie tylko w recce! "$IL_KOMCI", "$IL_UWAG"
fi
echo Recka "$NR", uwag "$IL_UWAG", komci "$IL_KOMCI"
