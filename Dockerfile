############################
# Jenkins with CloudBees Docker Workflow
# Used as the base image for smoll/jenkins-dood
############################

FROM jenkins:1.625.2
MAINTAINER Shujon Mollah <mollah@gmail.com>

#
# Install plugins
#
COPY plugins.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt
