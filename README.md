DynDNS replacement via AWS route 53
====

Based on: https://github.com/th0mi/ddns/blob/master/updateAws.sh - THX!

This little script was born out of a desire to get rid of DynDNS and similar services. There are several scripts around that do the job, but most of them are pretty complicated because they try to do the Amazon AWS calls manually.

This script requires a fully configured installation [AWS cli](http://aws.amazon.com/cli/) which is used to do the update.

## requirements
* `aws-cli`
* `curl`
* `dig`

#### aws-cli:
```
$ aws-cli configure
  > AWS Access Key ID [None]: XXX
  > AWS Secret Access Key [None]: YYY+ZZZ
  > Default region name [None]: eu-central-1
  > Default output format [None]: json
```

#### bin:
`# cp ./route53-update.sh /usr/local/bin/route53-update`

#### config:
`# cp ./route53-dyndns.conf /usr/local/etc/route53-dyndns-<CONF_NAME>.conf`

#### systemd:
```
# ln -s $(pwd)/route53-dyndns@.service /usr/lib/systemd/system/route53-dyndns@.service
# ln -s $(pwd)/route53-dyndns@.timer /usr/lib/systemd/system/route53-dyndns@.timer
# systemctl daemon-reload
# systemctl enable route53-dyndns@<CONF_NAME>.service
```

#### crontab:
`*/15 * * * * route53-update <ZONE_ID> <DOMAIN>`
