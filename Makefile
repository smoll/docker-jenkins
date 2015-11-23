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

# To manually rebuild this image without using cache (takes several minutes on my laptop), do:
# docker build -no-cache -t smoll/jenkins-nginx:latest nginx
nginx:
	@docker run -d \
		--name=jenkins-nginx \
		--link jenkins-master:jenkins-master \
		-p 80:80 -p 443:443 \
		smoll/jenkins-nginx:latest

slave:
	@cd slave; vagrant up

push:	build
	@docker push smoll/jenkins

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

# Easier than typing
open:
	@open "https://`docker-machine ip default`"

destroy:
	@cd slave; vagrant destroy -f

# Doesn't let us restore due to owner issue; fix this
backup:
	@mkdir -p ./tmp
	@docker cp jenkins-master:/var/jenkins_home ./tmp/jenkins_home

.DEFAULT_GOAL := build
.PHONY: build data clean-data nginx master slave push purge clean clean-nginx logs open destroy backup
