#!/bin/bash

# Script to search the Black Duck KB for components matching string
#
# Description:
# 	Returns a list of OSS components from the KB matching the supplied string
#
# Arguments:
#	string		Search for components matching "string" (required)
#

HUBURL="https://hubtesting.blackducksoftware.com"
APICODE="NzU1MDJmYjUtM2RjZC00ZjBiLTk5MWMtNTYyMGZkMDEyM2UzOjdkZmQxZTBhLTY0MzAtNDFhMC04MzYwLWE4OTMxZTI3OTgxNg=="

TEMPFILE=/tmp/bd1$$

error () {
	echo Error: $*
	end 1
}

end () {
	rm -f $TEMPFILE
	exit $1
}

if [ $# -eq 0 ]
then
	error Please specify a component string for matching
fi

COMPONENT=`echo $* | sed -e 's/ /%20/g'`
echo "Searching for component '$COMPONENT'"

echo Getting Auth Token ...
curl -X POST --header "Authorization: token $APICODE" --header "Accept:application/json" $HUBURL/api/tokens/authenticate > $TEMPFILE 2>/dev/null
if [ ! -f $TEMPFILE ]
then
	error API request failure
fi

TOKEN=`jq .bearerToken $TEMPFILE|sed -e 's/^"//' -e 's/"$//'`

echo Getting list of matching components ...
rm -f $TEMPFILE
curl -X GET --header "Authorization: Bearer $TOKEN" "${HUBURL}/api/search/components?q=name:$COMPONENT" > $TEMPFILE 2>/dev/null
if [ ! -f $TEMPFILE ]
then
	error API request failure
fi

COUNT=`jq .totalCount $TEMPFILE`
if [ "$COUNT" = "0" ]
then
	error No results returned
fi

Echo Found the following components:
jq '.items[].hits[].fields.name[]' $TEMPFILE

end 0