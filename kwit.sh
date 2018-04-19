#!/bin/bash

set -e

if [ $# -ne 3 ]; then
    echo Usage: $0 GitHub_user_who_owns_the_repo repo_name JSON_with_params
    exit 1
fi
. exportToken.sh
LAFK="LIttleAncientForestKami"

WHOSE=$1
REPO=$2
JSON=$3

curl -u "$LAFK":"$TOKEN" https://api.github.com/repos/$WHOSE/$REPO/issues -d @$JSON
