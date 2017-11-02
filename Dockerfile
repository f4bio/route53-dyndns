FROM alpine:latest
MAINTAINER Fabio Tea <iam@f4b.io> (http://iam.f4b.io)

RUN apk update
RUN apk upgrade
RUN apk add python py-pip curl python py-pip drill

RUN pip install awscli

ENTRYPOINT ["/usr/bin/bash"]
