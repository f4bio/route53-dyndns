#!/bin/bash
# Script retrieves the current IP Address from a standard German Telecom Router and
# uses this to update an Amazon AWS Route 53 zone
CURL="$(which curl) -ks"
TMPFILE=/tmp/`date +%Y%m%d_%H%M%S`.route53
AWSBIN="$(which aws)"
regexARecord="^[A-Za-z][A-Za-z0-9]{1,62}\.([A-Za-z0-9]{1,63}\.)?[A-Za-z0-9]{1,63}$"
regexZoneID="^Z[A-Z0-9]{13}$"

# TODO: --quiet option

#checks
if [ "$#" -ne 2 ]; then
	echo "usage: updateAws.sh <ZONEID> <ARECORD>"
	exit 1
fi
if [[ ! "$1" =~ $regexZoneID ]]; then
	echo "invald Zone ID. i.e: \"ZABCDEF1G2H3\""
	exit 2
fi
if [[ ! "$2" =~ $regexARecord ]]; then
	echo "invald A-Record. i.e: \"sub.main.domain\""
	exit 2
fi

#URL to the router page containing the current IP
URL="http://ipecho.net/plain"
# Amazon AWS hosted zone ID
ZONEID="$1"
# A record for your dyndns name
DYNHOST="$2"

# a public name server to check what the currently registered IP is
DNS=8.8.8.8

# GET IP FROM ROUTER
IP=$(${CURL} $URL | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')

# FIND CURRENTLY REGISTERED IP
REMOTEIP=`dig +short $DYNHOST @$DNS`

if [ "$REMOTEIP" == "$IP" -o "$REMOTEIP" == "" ]; then
   echo "$IP still current" > /dev/null
else
   echo "we need to update"
   #CREATE AWS UPDATE RECORD
   cat <<UPDATE-JSON > $TMPFILE
   {
     "Comment": "dyndns",
     "Changes": [
       {
         "Action": "UPSERT",
         "ResourceRecordSet": {
           "Name": "$DYNHOST",
           "Type": "A",
           "TTL": 300,
           "ResourceRecords": [
             {
               "Value": "$IP"
             }
           ]
         }
       }
     ]
   }
UPDATE-JSON
   echo "Updating IP to $IP"
   # do the update via AWS cli
   ${AWSBIN} route53 change-resource-record-sets --hosted-zone-id $ZONEID --change-batch file://$TMPFILE
   rm $TMPFILE
fi
