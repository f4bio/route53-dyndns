#!/bin/bash
# Script retrieves the current IP Address from a standard German Telecom Router and
# uses this to update an Amazon AWS Route 53 zone
SOURCE_DIR="/usr/local/src"
BIN_DIR="/usr/local/bin"
CONFIG_DIR="/usr/local/etc"
HOSTNAME=$ROUTE53_DYNDNS_HOSTNAME #sub.main.tld
HOSTNAME_TMP=$(echo $ROUTE53_DYNDNS_HOSTNAME | sed -r 's/\./_/g')

mkdir -p "$SOURCE_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$CONFIG_DIR"
cd "$SOURCE_DIR"

sudo -H git clone https://github.com:f4bio/route53-dyndns
sudo ln -s "$SOURCE_DIR"/route53-dyndns/route53-update.sh "$BIN_DIR"/route53-update
sudo ln -s "$SOURCE_DIR"/route53-dyndns/route53-update.conf "$CONFIG_DIR"/route53-update.conf
sudo cp "$SOURCE_DIR"/route53-dyndns/route53-dyndns.conf "$CONFIG_DIR"/route53-dyndns-"$HOSTNAME_TMP".conf
sudo cp "$SOURCE_DIR"/route53-dyndns/route53-dyndns@.service /etc/systemd/system/route53-dyndns@.service
sudo cp "$SOURCE_DIR"/route53-dyndns/route53-dyndns@.timer /etc/systemd/system/route53-dyndns@.timer

sudo systemctl daemon-reload
sudo systemctl enable route53-dyndns@"$HOSTNAME_TMP".timer

echo -e "####"
echo -e "now go and edit \"$CONFIG_DIR/route53-dyndns-$HOSTNAME_TMP.conf\"..."
echo -e "####"
