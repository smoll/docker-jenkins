# Makefile for development of these Docker images

build:
	@shipwright

master:	build
	@docker run -d  -p 50000:50000 -p 8080:8080 smoll/jenkins:latest > .makelog

slave:
	@cd slave; vagrant up

push:
	@shipwright push

purge:
	@shipwright purge

clean:
	@< .makelog xargs -I % sh -c 'docker kill %; docker rm -v %'
	@rm -f .makelog

destroy:
	@cd slave; vagrant destroy -f

.DEFAULT_GOAL := build
.PHONY: build master slave push purge clean destroy
