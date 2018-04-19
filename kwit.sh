#!/bin/bash

set -e

if [[ $# -ne 2 ]] && [[ $# -ne 3 ]]; then
    echo Usage:
    echo -ne "\t $0 GitHub_user_who_owns_the_repo/repo_name JSON_with_params"
    echo "or, in case when no template matches what you're after"
    echo -ne "\t $0 GitHub_user_who_owns_the_repo/repo_name issue_title issue_body"
    exit 1
fi
. exportToken.sh
LAFK="LIttleAncientForestKami"

REPO=$1
if (( $# == 2 )); then
    JSON=$2
    curl -u "$LAFK":"$PRIV_TOKEN" https://api.github.com/repos/"$REPO"/issues -d @"$JSON"
fi

if (( $# == 3 )); then
    TITLE=$2
    BODY=$3
    jq -n --arg t "$TITLE" --arg b "$BODY" -f kwity/szablon.json > json
    curl -u "$LAFK":"$PRIV_TOKEN" https://api.github.com/repos/"$REPO"/issues -d @json
    rm json
fi
