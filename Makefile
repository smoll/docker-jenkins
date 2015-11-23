# Makefile for development of these Docker images

build:
	@sh build-and-tag.sh

data:	build
	@docker run --name=jenkins-data smoll/jenkins-data:latest

clean-data:
	@docker rm -v jenkins-data

master:	build
	@docker run \
		--name=jenkins-master \
		--volumes-from=jenkins-data \
		-d \
		-p 8080:8080 \
		-p 50000:50000 \
		smoll/jenkins:latest

nginx:
	@docker run -d \
		--name=jenkins-nginx \
		--link jenkins-master:jenkins-master \
		-p 80:80 -p 443:443 \
		-e 'DH_SIZE=512' \
		-v /Users/smollah/workspace/jenkins/nginx/conf/:/etc/nginx/external/ \
		marvambass/nginx-ssl-secure

slave:
	@cd slave; vagrant up

push:
	# Don't push while we experiment with security settings

purge:
	@docker images -qf dangling=true | xargs docker rmi

clean:
	@docker kill jenkins-master || true
	@docker rm jenkins-master || true

clean-nginx:
	@docker kill jenkins-nginx || true
	@docker rm jenkins-nginx || true

logs:
	@docker logs -f jenkins-nginx

open:
	@open "https://jenkins.example.com"

destroy:
	@cd slave; vagrant destroy -f

backup:
	@mkdir -p ./tmp
	@docker cp jenkins-master:/var/jenkins_home ./tmp/jenkins_home

.DEFAULT_GOAL := build
.PHONY: build data clean-data nginx master slave push purge clean clean-nginx logs open destroy backup
