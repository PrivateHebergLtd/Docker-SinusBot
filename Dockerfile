# ==================
#  SinusBot Dockerfile
#   PrivateHeberg©
# ==================

FROM ubuntu:xenial
MAINTAINER PrivateHeberg (PHClement)

ENV PORT=1023


#Prerequisites
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install x11vnc xinit xvfb libxcursor1 ca-certificates bzip2 libglib2.0-0 wget curl python2.7 libssl-dev libffi-dev python-dev
RUN update-ca-certificates
RUN curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl && chmod a+rx /usr/local/bin/youtube-dl

#Downloads
RUN mkdir /opt/ts3soundboard/
RUN cd /opt/ts3soundboard/ && wget https://www.sinusbot.com/pre/sinusbot-0.9.18-8499d2c.tar.bz2
RUN cd /opt/ts3soundboard/ && wget http://teamspeak.gameserver.gamed.de/ts3/releases/3.0.19.4/TeamSpeak3-Client-linux_amd64-3.0.19.4.run

#Setting Up Files
ADD config.ini /opt/ts3soundboard/config.ini
RUN cd /opt/ts3soundboard/ && tar -xjvf sinusbot-0.9.18-8499d2c.tar.bz2
RUN cd /opt/ts3soundboard/ && chmod 0755 TeamSpeak3-Client-linux_amd64-3.0.19.4.run
RUN sed -i 's/^MS_PrintLicense$//' /opt/ts3soundboard/TeamSpeak3-Client-linux_amd64-3.0.19.4.run
RUN cd /opt/ts3soundboard && ./TeamSpeak3-Client-linux_amd64-3.0.19.4.run
RUN cd /opt/ts3soundboard/ && cp plugin/libsoundbot_plugin.so /opt/ts3soundboard/TeamSpeak3-Client-linux_amd64/plugins
RUN chown -R root:root /opt/ts3soundboard
RUN cd /opt/ts3soundboard/ && chmod 755 sinusbot

# Add a startup script
COPY run.sh /run.sh


VOLUME ["/opt/ts3soundboard/data"]
EXPOSE $PORT

ENTRYPOINT ["/run.sh"]
