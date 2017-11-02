#!/bin/bash
# update an Amazon AWS Route 53 zone

hostname=${1:-"sub.main.domain"}
sourceDir="/usr/local/src" # ${2:${ROUTE53_DYNDNS_SOURCE_DIR:-"/usr/local/src"}}
binDir="/usr/local/bin" # ${3:${ROUTE53_DYNDNS_BIN_DIR:-"/usr/local/bin"}}
confDir="/usr/local/etc" # ${4:${ROUTE53_DYNDNS_CONF_DIR:-"/usr/local/bin"}}
hostnameFormatted=${hostname//./_}

# for prod:
# cd $sourceDir
# sudo -H git clone https://github.com:f4bio/route53-dyndns

# for dev:
sudo cp -r ../route53-dyndns $sourceDir/ || { echo -e "\nmaybe need sudo?" ; exit 1; }

sudo cp --force $sourceDir/route53-dyndns/route53-dyndns-update.sh $binDir/route53-dyndns-update
sudo cp --force $sourceDir/route53-dyndns/route53-dyndns.conf $confDir/route53-dyndns-$hostnameFormatted.conf

cp $sourceDir/route53-dyndns/route53-dyndns@.service $HOME/.config/systemd/user/route53-dyndns@.service
cp $sourceDir/route53-dyndns/route53-dyndns@.timer $HOME/.config/systemd/user/route53-dyndns@.timer
systemctl --user daemon-reload
systemctl --user enable route53-dyndns@$hostnameFormatted.timer
systemctl --user restart route53-dyndns@$hostnameFormatted.service
