#!/bin/bash

set -e

if [[ $# -ne 3 ]] && [[ $# -ne 4 ]]; then
    echo Usage:
    echo -ne "\t $0 GitHub_user_who_owns_the_repo repo_name JSON_with_params"
    echo "or, in case when no template matches what you're after"
    echo -ne "\t $0 GitHub_user_who_owns_the_repo repo_name issue_title issue_body"
    exit 1
fi
. exportToken.sh
LAFK="LIttleAncientForestKami"

WHOSE=$1
REPO=$2
if (( $# == 3 )); then
    JSON=$3
    curl -u "$LAFK":"$TOKEN" https://api.github.com/repos/"$WHOSE"/"$REPO"/issues -d @"$JSON"
fi

if (( $# == 4 )); then
    TITLE=$3
    BODY=$4
    jq -n --arg t "$TITLE" --arg b "$BODY" -f kwity/szablon.json > json
    curl -u "$LAFK":"$TOKEN" https://api.github.com/repos/"$WHOSE"/"$REPO"/issues -d @json
    rm json
fi
