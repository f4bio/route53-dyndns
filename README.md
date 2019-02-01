DynDNS via AWS route 53
====

maybe switching to containerized solution using [tasker](https://github.com/opsxcq/tasker)


Based on: https://github.com/th0mi/ddns/blob/master/updateAws.sh - THX!

This little script was born out of a desire to get rid of DynDNS and similar services. There are several scripts around that do the job, but most of them are pretty complicated because they try to do the Amazon AWS calls manually.

This script requires a fully configured installation [AWS cli](http://aws.amazon.com/cli/) which is used to do the update.

## requirements
* `aws-cli`
* `curl`
* `drill` (`ldnsutils`)
* `dig` (`dnsutils`)
* `A` and/or `AAAA` records of (sub-)domain to be used

#### aws-cli:
```
$ aws configure
  > AWS Access Key ID [None]: XXX
  > AWS Secret Access Key [None]: YYY+ZZZ
  > Default region name [None]: eu-central-1
  > Default output format [None]: json
```

## setup
#### bin:
`# ln -s $(pwd)/route53-dyndns-update.sh /usr/local/bin/route53-dyndns-update`

#### config:
* `# cp $(pwd)/route53-dyndns.conf /usr/local/etc/route53-dyndns-<CONF_NAME>.conf`
* and edit

#### systemd:
```
$ cp $(pwd)/route53-dyndns@.service $HOME/.config/systemd/user/route53-dyndns@.service
$ cp $(pwd)/route53-dyndns@.timer $HOME/.config/systemd/user/route53-dyndns@.timer
$ systemctl --user daemon-reload
$ systemctl --user enable route53-dyndns@<CONF_NAME>.timer
$ systemctl --user restart route53-dyndns@<CONF_NAME>.timer
```
