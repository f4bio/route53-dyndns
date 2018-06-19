FROM alpine:latest
MAINTAINER Fabio Tea <iam@f4b.io> (http://iam.f4b.io)

RUN apk update
RUN apk upgrade
RUN apk add python py-pip curl python py-pip drill

RUN pip install awscli
RUN apk -v --purge del py-pip
RUN rm /var/cache/apk/*
# RUN rc-service crond start && rc-update add crond

COPY route53-dyndns-update.sh /etc/periodic/15min/route53-dyndns-update.sh

# ENTRYPOINT ["/bin/sh"]
CMD ["crond", "-l 2", "-f"]
