
# http://docs.docker.io/en/latest/use/builder/

FROM ubuntu
MAINTAINER Hidenori Suzuki <hidenori.suzuki@yahoo.com>

# make sure the package repository is up to date
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive

# Install build requirements
RUN apt-get update
RUN apt-get install -y build-essential curl openjdk-7-jdk

# Download and Install HBase
ENV HBASE_VERSION 1.0.1

RUN mkdir -p /opt/downloads && cd /opt/downloads && curl -SsfLO "http://archive.apache.org/dist/hbase/hbase-$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz"
RUN cd /opt && tar xvfz /opt/downloads/hbase-$HBASE_VERSION-bin.tar.gz
RUN mv /opt/hbase-$HBASE_VERSION /opt/hbase

# Data will go here (see hbase-site.xml)
RUN mkdir -p /data/hbase /opt/hbase/logs

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV HBASE_SERVER /opt/hbase/bin/hbase
ENV PATH /opt:/opt/hbase/bin:$PATH

ADD ./hbase-site.xml /opt/hbase/conf/hbase-site.xml

ADD ./zoo.cfg /opt/hbase/conf/zoo.cfg

ADD ./hbase-server /opt/hbase-server

# Rest API
EXPOSE 8080
# Thrift API
EXPOSE 9090
# Thrift Web UI
EXPOSE 9095
# HBase's zookeeper - used to find servers
EXPOSE 2181
## HBase Master API port ??
#EXPOSE 16000
# HBase Master web UI at :15010/master-status;  ZK at :16010/zk.jsp
EXPOSE 16010
# Region server API port
EXPOSE 16020
# HBase Region server web UI at :16030/rs-status
EXPOSE 16030

CMD ["/opt/hbase-server"]
