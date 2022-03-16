###############################################################################
## Dockerizing Mule EE
## Version:  1.0
## Based on:  java:8-jre (Trusted Java from http://java.com)
###############################################################################

FROM                    java:8-jre
MAINTAINER              TJ Mai <tung.mai@mulesoft.com>
ENV                     DEBIAN_FRONTEND noninteractive

###############################################################################
## Setting up the arguments
ARG     muleVersion=4.2.2
ARG     muleDistribution=mule-ee-distribution-standalone-$muleVersion.tar.gz
ARG     muleHome=/opt/mule-enterprise-standalone-$muleVersion

###############################################################################
## Base container configurations
RUN     echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
RUN     echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN     sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
RUN     apt-get -o Acquire::Check-Valid-Until=false update
RUN     echo "Acquire::Check-Valid-Until false;" | tee -a /etc/apt/apt.conf.d/10-nocheckvalid

# Install base pre-requisites
RUN     apt-get update
RUN     apt-get upgrade -yq
RUN     apt-get install -yq apt-utils && apt-get install -yq curl && apt-get install -yq jq

###############################################################################
## MuleEE installation:

## Install Mule EE
WORKDIR /opt/
COPY    ./$muleDistribution /opt/
#RUN     echo "7dc3bae84bf8b7b1de929c739514f9f9 /opt/$muleDistribution" | md5sum -c
RUN     tar -xzvf /opt/$muleDistribution
RUN     ls
RUN     ln -s $muleHome/ mule
RUN     ls -l mule
RUN     rm -f $muleDistribution

## Copy the License file - pre-package into docker image to avoid leakage
# ADD     ./mule-ee-license.lic /opt/mule/conf/
# RUN     /opt/mule/bin/mule -installLicense /opt/mule/conf/mule-ee-license.lic
# RUN     rm -f /opt/mule/conf/mule-ee-license.lic

## Copy the mule start/stop script
ADD     ./startMule.sh /opt/mule/bin/
RUN     chmod 755 /opt/mule/bin/startMule.sh

###############################################################################
## Configure mule runtime access pre-requisites

## HTTPS Port for Anypoint Platform communication
EXPOSE  443

## Mule remote debugger
#EXPOSE  5000

## Mule JMX port (must match Mule config file)
EXPOSE  1098

## Mule Cluster ports
EXPOSE 5701
EXPOSE 54327

###############################################################################
## Expose the necessary port ranges as required by the apps to be deployed

## HTTP Service Port
EXPOSE 8081

## HTTPS Service Port
EXPOSE 8082

###############################################################################

## Environment and execution:
ENV             MULE_BASE /opt/mule
WORKDIR         /opt/mule/bin
ENTRYPOINT      ["/opt/mule/bin/startMule.sh"]
