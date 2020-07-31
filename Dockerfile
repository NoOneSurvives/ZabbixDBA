FROM debian:buster-slim

ENV MAIN='perl'
ENV ORAPART='libaio wget unzip'
ENV BUILD_DEPS='curl make gcc libc-dev perl-base'

RUN mkdir /zdba
WORKDIR /zdba

COPY cpanfile /zdba

RUN apt-get update && apt-get install -y
RUN apt install -y $MAIN


#####
WORKDIR /opt/oracle
RUN apt-get install -y $ORAPART \
     && wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip \
	 && wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linuxx64.zip \
	 && wget https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip \
     && unzip instantclient-basiclite-linuxx64.zip && unzip instantclient-sqlplus-linuxx64.zip && unzip instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip \
     && rm -f instantclient-basiclite-linuxx64.zip instantclient-sqlplus-linuxx64.zip instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip\
     && cd /opt/oracle/instantclient* \
	 && export LD_LIBRARY_PATH=/opt/oracle/instantclient*/ \
     && rm -f *jdbc* *occi* *mysql* *README *jar uidrvci genezi adrci \
     && echo /opt/oracle/instantclient* > /etc/ld.so.conf.d/oracle-instantclient.conf \
     && ldconfig

#####

WORKDIR /zdba
RUN apt install -y $BUILD_DEPS && \
    (curl -L https://cpanmin.us | perl - App::cpanminus) && \
    cpanm --installdeps . && \
	cpanm DBD::Oracle
    rm -rf /root/.cpanm/work

COPY . /zdba

VOLUME ["/zdba/conf", "/zdba/log"]

CMD ["/usr/bin/perl", "/zdba/zdba.pl", "/zdba/conf/config.pl"]
