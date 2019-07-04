FROM    debian:stretch
RUN     apt-get update && apt-get install -y --no-install-recommends debirf mtools genisoimage
WORKDIR /docker
ADD     provision.sh /docker/provision.sh
RUN     provision.sh
COPY    debstack     /docker/debstack
USER    dev
WORKDIR /home/dev/work
#RUN    debirf make debstack
#RUN    debirf makeiso debstack

