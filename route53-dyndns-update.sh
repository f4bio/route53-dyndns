#!/bin/bash
# Script retrieves the current IP Address from a standard German Telecom Router and
# uses this to update an Amazon AWS Route 53 zone
CURL="$(which curl) -ks"
TMPFILE4="$(mktemp).4.route53"
TMPFILE6="$(mktemp).6.route53"
AWSBIN="$(which aws)"
regexDomainRecord="^[A-Za-z][A-Za-z0-9]{1,62}\.([A-Za-z0-9]{1,63}\.)?[A-Za-z0-9]{1,63}$"
regexZoneID="^Z[A-Z0-9]{13}$"

#checks
if [[ ! "${AWS_ZONE_ID}" =~ $regexZoneID ]]; then
  echo "invald Zone ID (${AWS_ZONE_ID}). ex.: \"ZABCDEF1G2H3\""
  exit 2
fi
if [[ ! "${AWS_DOMAIN_RECORD}" =~ $regexDomainRecord ]]; then
  echo "invald Domain Record (${AWS_DOMAIN_RECORD}) ex.: \"sub.main.tld\""
  exit 2
fi

#URL to the router page containing the current IP
URL="https://wtfismyip.com/text"
# Amazon AWS hosted zone ID
ZONEID="${AWS_ZONE_ID}"
# A record for your dyndns name
DYNHOST="${AWS_DOMAIN_RECORD}"

# a public name server to check what the currently registered IP is
DNS4=1.1.1.1
DNS6=2606:4700:4700::1111

# GET IP FROM ROUTER
# IP=$(${CURL} $URL | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
#IP=$(${CURL} $URL | grep "var wan_ip" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
IP4=$(${CURL} -4 $URL)
IP6=$(${CURL} -6 $URL)

# FIND CURRENTLY REGISTERED IP
# REMOTEIP=`dig +short $DYNHOST @$DNS`
# REMOTEIP=`drill $DYNHOST @$DNS | grep "^$DYNHOST" | cut -f 5`
REMOTEIP4=`dig A +short $DYNHOST @$DNS4`
REMOTEIP6=`dig AAAA +short $DYNHOST @$DNS6`

## check and ipdate ipv4
if [ "$REMOTEIP4" == "$IP4" -o "$REMOTEIP4" == "" ]
then
  echo "$IP4 still current" > /dev/null
else
  echo "IPv4 needs an update"
  #CREATE AWS UPDATE RECORD
  cat <<UPDATE-JSON > $TMPFILE4
   {
     "Comment": "automatic route53-dyndns A update",
     "Changes": [
       {
         "Action": "UPSERT",
         "ResourceRecordSet": {
           "Name": "$DYNHOST",
           "Type": "A",
           "TTL": 300,
           "ResourceRecords": [
             {
               "Value": "$IP4"
             }
           ]
         }
       }
     ]
   }
UPDATE-JSON
  echo "Updating IPv4 to $IP4"
  # do the update via AWS cli
  ${AWSBIN} route53 change-resource-record-sets --hosted-zone-id $ZONEID --change-batch file://$TMPFILE4
  rm $TMPFILE4
fi

# check and update ipv6
if [ "$REMOTEIP6" == "$IP6" -o "$REMOTEIP6" == "" ]; then
  echo "$IP6 still current" > /dev/null
else
  echo "IPv6 needs an update"
  #CREATE AWS UPDATE RECORD
  cat <<UPDATE-JSON > $TMPFILE6
   {
     "Comment": "automatic route53-dyndns AAAA update",
     "Changes": [
       {
         "Action": "UPSERT",
         "ResourceRecordSet": {
           "Name": "$DYNHOST",
           "Type": "AAAA",
           "TTL": 300,
           "ResourceRecords": [
             {
               "Value": "$IP6"
             }
           ]
         }
       }
     ]
   }
UPDATE-JSON
  echo "Updating IPv6 to $IP6"
  # do the update via AWS cli
  ${AWSBIN} route53 change-resource-record-sets --hosted-zone-id $ZONEID --change-batch file://$TMPFILE6
  rm $TMPFILE6
fi
