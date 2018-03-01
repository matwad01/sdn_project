# Mininet

FROM ubuntu:16.04

MAINTAINER WADAS Mateusz <mateuszwadas23@gmail.com@gmail.com>

# ftp server
#
# VERSION               0.0.3
#
# Links:
# - https://help.ubuntu.com/community/PureFTP
# - http://www.dikant.de/2009/01/22/setting-up-pureftpd-on-a-virtual-server/
# - http://download.pureftpd.org/pub/pure-ftpd/doc/README


RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y inetutils-ftp nano wget


#
# Install supervisord (used to handle processes)
# ----------------------------------------------
#
# Installation with easy_install is more reliable. apt-get don't always work.

RUN apt-get install -y python python-setuptools
RUN easy_install supervisor

ADD ./etc-supervisord.conf /etc/supervisord.conf
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor/


#
# Setup rsyslog
# ---------------------------

RUN apt-get install -y rsyslog

ADD ./etc-rsyslog.conf /etc/rsyslog.conf
ADD ./etc-rsyslog.d-50-default.conf /etc/rsyslog.d/50-default.conf


#
# Download and build pure-ftp
# ---------------------------

RUN wget http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.46.tar.gz
RUN tar -xzf pure-ftpd-1.0.46.tar.gz

RUN apt-get build-dep -y pure-ftpd

RUN cd /pure-ftpd-1.0.46; ./configure optflags=--with-everything --with-privsep --without-capabilities
RUN cd /pure-ftpd-1.0.46; make; make install


#
# Configure pure-ftpd
# -------------------

RUN mkdir -p /etc/pure-ftpd/conf

RUN echo yes > /etc/pure-ftpd/conf/ChrootEveryone
RUN echo no > /etc/pure-ftpd/conf/PAMAuthentication
RUN echo yes > /etc/pure-ftpd/conf/UnixAuthentication
RUN echo "30000 30009" > /etc/pure-ftpd/conf/PassivePortRange
RUN echo "10" > /etc/pure-ftpd/conf/MaxClientsNumber

# Needed in AWS, check the IP of the server (not sure how this works in docker)
#RUN echo "YOURIPHERE" > ForcePassiveIP
#RUN echo "yes" > DontResolve


#
# Setup users, add as many as needed
# ----------------------------------

RUN useradd -m -s /bin/bash someone
RUN echo someone:password |chpasswd


#
# Start things
# -------------

ADD ./start.sh /start.sh

EXPOSE 20 21 30000 30001 30002 30003 30004 30005 30006 30007 30008 30009


RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    openssh-client \
    nano \
    git \
    iproute2 \
    iputils-ping \
    mininet \
    net-tools \
    tcpdump \
    screen \
    x11-xserver-utils \
    xterm \
 && rm -rf /var/lib/apt/lists/* \
 && mv /bin/ping /sbin/ping \
 && mv /bin/ping6 /sbin/ping6 \
 && mv /usr/sbin/tcpdump /usr/bin/tcpdump 

# Update the apt information
# Install OpenJDK 8 in headless mode
# Install wget
# Download distribution-karaf-0.4.1-Beryllium-SR1.tar.gz
# Install (unzip) OpenDaylight

RUN apt-get update && \
    apt-get -y install openjdk-8-jre-headless \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "Download distribution-karaf-0.4.1-Beryllium-SR1.tar.gz and install" && \
    wget -q -O /opt/odl.tar.gz "http://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.4.1-Beryllium-SR1/distribution-karaf-0.4.1-Beryllium-SR1.tar.gz" && \
    tar -C /opt -xzf /opt/odl.tar.gz && \
    rm /opt/odl.tar.gz

# Set JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/


# 12001 - ODL Clustering
EXPOSE 6633 8080 8101 8181 6653 6640


# Define working directory.
WORKDIR /opt/distribution-karaf-0.4.1-Beryllium-SR1/bin

RUN sed -i '/^featuresBoot=/ s/$/,\
                         odl-netconf-api,\
                         odl-netconf-mapping-api,\
                         odl-netconf-util,\
                         odl-netconf-impl,\
                         odl-config-netconf-connector,\
                         odl-netconf-netty-util,\
                         odl-netconf-monitoring,\
                         odl-netconf-notifications-api,\
                         odl-netconf-notifications-impl,\
                         odl-yangtools-models,\
                         odl-yangtools-data-binding,\
                         odl-yangtools-binding,\
                         odl-yangtools-binding-generator,\
                         http,\
                         war,\
                         odl-config-persister,\
                         odl-config-startup,\
                         pax-jetty,\
                         pax-http,\
                         pax-http-whiteboard,\
                         pax-war,\
                         odl-akka-scala,\
                         odl-akka-system,\
                         odl-akka-clustering,\
                         odl-akka-leveldb,\
                         odl-akka-persistence,\
                         odl-mdsal-common,\
                         odl-mdsal-broker-local,\
                         odl-mdsal-clustering-commons,\
                         odl-mdsal-distributed-datastore,\
                         odl-mdsal-remoterpc-connector,\
                         odl-mdsal-broker,\
                         odl-config-netty,\
                         odl-aaa-authn,\
                         odl-restconf,\
                         odl-restconf-noauth/' /opt/distribution-karaf-0.4.1-Beryllium-SR1/etc/org.apache.karaf.features.cfg 




