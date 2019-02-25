#!/bin/bash

# Script to create a list of project/versions which violate policies
#
# Description:
# 	Extracts a list of all policies (or a subset specified by search string)
#	Reports which policies are violated within all versions within all projects (up to 1000)
#	Will write list of policy violated, project name, version name and URL to policies_versions.csv
#	If output file policies_versions.csv exists will terminate unless -f option is specified
#
# Arguments:
#	-f			Remove existing output file policies_versions.csv (optional)
#	string		Search for policies with name matching "string" only (optional)
#

HUBURL="https://hubtesting.blackducksoftware.com"
APICODE=""

TEMPFILE=/tmp/bd$$
OUTFILE=policies_versions.csv

error () {
	echo Error: $*
	end 1
}

end () {
	rm -f $TEMPFILE
	exit $1
}

if [ "$1" == "-f" ] || [ "$1" == "-F" ]
then
	rm -f $OUTFILE
	shift
fi

if [ -r $OUTFILE ]
then
	error $OUTFILE exists already - please delete or use option -f
fi

if [ -z "$APICODE" ]
then
	error "Please set the API code and BD Server URL"
fi

POLICYSTRING=`echo $* | sed -e 's/ /%20/g'`
if [ ! -z "$POLICYSTRING" ]
then
	POLQUERY='?q=name:'"$POLICYSTRING"
	echo "Will search for policies matching '$POLICYSTRING'"
else
	POLQUERY=
fi

echo "Getting Auth Token from $HUBURL ..."
curl -X POST --header "Authorization: token $APICODE" --header "Accept:application/json" $HUBURL/api/tokens/authenticate > $TEMPFILE 2>/dev/null

TOKEN=`jq -r .bearerToken $TEMPFILE`

#echo Getting list of policies ...
#curl -X GET --header "Authorization: Bearer $TOKEN" "https://hubtesting.blackducksoftware.com/api/search/components?q=name:$COMPONENT" > $TEMPFILE 2>/dev/null
curl -X GET --header "Authorization: Bearer $TOKEN" "$HUBURL/api/policy-rules$POLQUERY" > $TEMPFILE 2>/dev/null
if [ ! -f $TEMPFILE ]
then
	error Cannot get list of policies
fi

COUNT=`jq -r .totalCount $TEMPFILE`
if [ "$COUNT" = "0" ]
then
	error No policies returned
else
	echo "$COUNT Policies Returned"
fi

#POLICIESJSON="`jq '[.items[]|{name: .name, href: ._meta.href}]' $TEMPFILE`"
POLNAMES="`jq -r '[.items[].name]|@csv' $TEMPFILE`"
POLURLS="`jq -r '[.items[]._meta.href]|@csv' $TEMPFILE`"
POLIDS="`jq -r '.items[]._meta.href' $TEMPFILE | while read POLURL
do
	echo -n $(basename $POLURL),
done`"

#Get all projects
rm -f $TEMPFILE
curl -X GET --header "Authorization: Bearer $TOKEN" $HUBURL/api/projects?limit=1000 > $TEMPFILE 2>/dev/null
if [ $? -ne 0 ] || [ ! -r $TEMPFILE ]
then
	error Error getting projects
fi
#PROJECTSJSON="`jq '[.items[]|{name: .name, href: ._meta.href}]' $TEMPFILE`"
PROJNAMES="`jq -r '[.items[].name]|@csv' $TEMPFILE`"
PROJURLS="`jq -r '[.items[]._meta.href]|@csv' $TEMPFILE`"

echo "Policy Name,Project Name,Version Name,Version URL" > $OUTFILE

PROJNUM=0
IFS=','
for PROJURL in $PROJURLS
do
	IFS=
	PROJNAME="`echo $PROJNAMES | cut -f$((PROJNUM+1)) -d,`"
	IFS=','

	echo Processing Project $PROJNAME
	rm -f $TEMPFILE
	curl -X GET --header "Authorization: Bearer $TOKEN" ${PROJURL//[\"]}/versions 2>/dev/null >$TEMPFILE
	VERNAMES="`jq -r '[.items[].versionName]|@csv' $TEMPFILE`"
	VERURLS="`jq -r '[.items[]._meta.href]|@csv' $TEMPFILE`"
	
	VERNUM=0
	IFS=','
	for VERURL in $VERURLS
	do
		IFS=
		VERNAME="`echo $VERNAMES | cut -f$((VERNUM+1)) -d,`"
		IFS=','
		
		echo "    Processing Version $VERNAME"
		
		rm -f $TEMPFILE
		curl -X GET --header "Authorization: Bearer $TOKEN" ${VERURL//[\"]}/policy-rules 2>/dev/null >$TEMPFILE
		jq -r '.items[].id' $TEMPFILE | while read POLVIOLATED
		do
			POLNUM=0
			for pol in $POLIDS
			do
				if [ "$POLVIOLATED" == "$pol" ]
				then
					IFS=
					POLNAME="`echo $POLNAMES | cut -f$((POLNUM+1)) -d,`"
					IFS=','
					echo "$POLNAME,$PROJNAME,$VERNAME,$VERURL" >> $OUTFILE
					break
				fi
				((POLNUM++)) 
			done
		done
		((VERNUM++))
	done
	((PROJNUM++))
done

end 0
