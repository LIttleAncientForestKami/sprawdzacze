#!/bin/bash

set -e
#set -v

K="/home/tammo/rdzy/projekty/sprawdzacze/kwity"

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
    echo Usage:
    echo -ne "\t $0 JSON_with_params"
    echo "or, in case when no template matches what you're after"
    echo -ne "\t $0 issue_title issue_body"
    echo -ne "Script works only with SSH GitHub urls for now, when trying to find out GitHub_user_who_owns_the_repo/repo_name combo."
    exit 1
fi
. exportToken
LAFK="LIttleAncientForestKami"

# TODO: fix url parsing for HTTP (19 znaków po?)
REPO_SSH_URL=$(git remote get-url origin | awk -F ':' '{print $2}')
REPO=${REPO_SSH_URL%.git}
# TODO: test if the repo is parsed well before continuing
if (( $# == 1 )); then
    JSON="$K"/"$1"
    curl -u "$LAFK":"$PRIV_TOKEN" https://api.github.com/repos/"$REPO"/issues -d @"$JSON"
fi

if (( $# == 2 )); then
    TITLE=$1
    BODY=$2
    jq -n --arg t "$TITLE" --arg b "$BODY" -f "$K"/szablon.json > json
    curl -u "$LAFK":"$PRIV_TOKEN" https://api.github.com/repos/"$REPO"/issues -d @json
    rm json
fi
