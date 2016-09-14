DynDNS replacement via AWS route 53
====

Based on: https://github.com/th0mi/ddns/blob/master/updateAws.sh - THX!

This little script was born out of a desire to get rid of DynDNS and similar services. There are several scripts around that do the job, but most of them are pretty complicated because they try to do the Amazon AWS calls manually.

This script requires a fully configured installation [AWS cli](http://aws.amazon.com/cli/) which is used to do the update.

crontab:
`*/15 * * * * /path/to/script/route53-dyndns/update-zone.sh <ZONE_ID> <DOMAIN> >> /path/to/script/route53-dyndns/update-zone.log`
