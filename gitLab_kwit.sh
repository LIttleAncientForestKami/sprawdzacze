#!/bin/bash

REPO="${1}%2F${2}"
. exportToken.sh
TYTUL="$(echo "$1" | sed 's/ /%20/g')"
CO="$(echo "$2" | sed 's/ /%20/g')"
TYP=${3:-"bug"}
curl --request POST --header "PRIVATE-TOKEN: $GL_TOKEN" "https://git.epam.com/api/v4/projects/$REPO/issues?title=$TYTUL&description=$CO&labels=$TYP"
