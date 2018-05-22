#!/bin/bash
. exportToken.sh
. exportUser
LOG=$0_tmp_repos
echo type=all by default, want to have only yours, run with "\?type=owner"
echo see https://developer.github.com/v3/repos/#list-your-repositories for more params
echo if you have more than 30 repositories, consider "\?per_page=100" or "\?page=numberHere"
sleep 2
echo
curl -f -u "$LAFK":"$TOKEN" https://api.github.com/user/repos$1 > $LOG
jq .'[].full_name' < $LOG
NR=$(grep -c full_name $LOG)
echo Found $NR repositories
if [[ $NR = 30 ]]; then
	echo Remember the paging tip. "\?per_page=100" was max for GH API v3.
fi
if [[ $NR = 100 ]]; then
	echo Max per page number. Not bad, man! Next page can be retrieved with "\?page=2" for GH API v3.
fi
rm $LOG
