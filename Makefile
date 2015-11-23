# Makefile for development of these Docker images

build:
	@shipwright

data:
	@docker run --name=jenkins-data smoll/jenkins-data:latest

clean-data:
	@docker rm -v jenkins-data

master:	build
	@docker run -p 8080:8080 -p 50000:50000 --name=jenkins-master --volumes-from=jenkins-data -d smoll/jenkins:latest

slave:
	@cd slave; vagrant up

push:
	# Don't push while we experiment with security settings
	#@shipwright push

purge:
	@shipwright purge

clean:
	@docker kill jenkins-master
	@docker rm jenkins-master

destroy:
	@cd slave; vagrant destroy -f

backup:
	@mkdir -p ./tmp
	@docker cp jenkins-master:/var/jenkins_home ./tmp/jenkins_home

.DEFAULT_GOAL := build
.PHONY: build data clean-data master slave push purge clean destroy backup
