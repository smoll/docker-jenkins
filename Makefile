# Makefile for development of these Docker images

build:
	@shipwright

run-data:
	@docker run --name=jenkins-data smoll/data-wont-push:latest

clean-data:
	@docker rm -v jenkins-data

master:	build
	@docker run -p 8080:8080 -p 50000:50000 --name=jenkins-master --volumes-from=jenkins-data -d smoll/jenkins:latest

slave:
	@cd slave; vagrant up

push:
	@shipwright push

purge:
	@shipwright purge

clean:
	@docker kill jenkins-master
	@docker rm jenkins-master

destroy:
	@cd slave; vagrant destroy -f

.DEFAULT_GOAL := build
.PHONY: build run-data clean-data master slave push purge clean destroy
