# Firebird 2.1 SuperServer container based on
# almeida/firebird Dockerfile
#
FROM ubuntu:precise
MAINTAINER Enrique Gil <mahoul@gmail.com>

ENV DEBIAN_FRONTEND noninteractive 

# Install firebird 
RUN \
  sed -i 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list && \
  apt-get clean && \
  apt-get update && \
  apt-get install -y firebird2.1-super less lsof net-tools psmisc pv rsync supervisor vim && \
  sed -ri 's/RemoteBindAddress = localhost/RemoteBindAddress = /g' /etc/firebird/2.1/firebird.conf && \
  sed -i 's/^ENABLE_SUPER_SERVER.*/ENABLE_SUPER_SERVER=yes/g' /etc/default/firebird2.1-super && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ADD SYSDBA.password /etc/firebird/2.1/
ADD fbstart.conf /etc/supervisor/conf.d/fbstart.conf
ADD startfb.sh /startfb.sh
ADD backup.sh  /opt/admin/scripts/backres/backup.sh
ADD restore.sh /opt/admin/scripts/backres/restore.sh

# forward logs to docker log collector 
RUN ln -sf /dev/stdout /var/log/firebird2.1.log && \
  mkdir -p /var/run/firebird/2.1 && \
  chown -R firebird:firebird /opt/admin/scripts/backres /var/lib/firebird /var/run/firebird && \
  chmod 600 /etc/firebird/2.1/SYSDBA.password && \
  chmod +x /startfb.sh && \
  chmod 775 /opt/admin/scripts/backres/*.sh

VOLUME /var/lib/firebird/2.1/data 
VOLUME /var/lib/firebird/2.1/backup 
VOLUME /opt/admin/scripts/backres/log
VOLUME /opt/admin/scripts/backres/tmp


EXPOSE 3050 

CMD [ "/usr/bin/supervisord", "-n" ]

