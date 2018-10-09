#!/bin/bash
set -e
curl -sf -u LIttleAncientForestKami -i https://api.github.com/user | grep X-RateLimit- > tmp
tee < tmp | head -3
RESET=$(grep Reset: tmp | cut -d " " -f 2)
echo Reset API Githuba nastąpi $(date --date="@$RESET"), jest $(date +%H:%M)
