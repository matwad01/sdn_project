FROM ubuntu:trusty
MAINTAINER Mateusz Wadas 

# Install packages (this is generic version with all required extensions).
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor git curl unzip mininet netcat ftpd

# Configure open ssh
# See: http://docs.docker.com/examples/running_ssh_service/ for more details
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /etc/profile

# Install tools required for behat testings
# Firefox
# Selenium
# Xvfb and x11vnc
RUN apt-get -y install xvfb x11vnc firefox openjdk-7-jre openbox
RUN mkdir /usr/local/lib/selenium && curl http://selenium-release.storage.googleapis.com/2.46/selenium-server-standalone-2.46.0.jar -o /usr/local/lib/selenium/selenium.jar


# Install helper tools
RUN apt-get -y install vim nano

EXPOSE 80 22

