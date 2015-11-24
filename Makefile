# Makefile for development of these Docker images

all:	build data master nginx
clean:	clean-nginx clean-master clean-data

# docker tagging, pushing, and deleting images

build:
	@sh build-and-tag.sh

push:
	@docker push smoll/jenkins

purge:
	@docker images -qf dangling=true | xargs docker rmi

# docker running and removing containers

data:
	@docker run --name=jenkins-data smoll/jenkins-data:latest

clean-data:
	@docker rm -v jenkins-data

master:
	@docker run \
		--name=jenkins-master \
		--volumes-from=jenkins-data \
		-d \
		-p 50000:50000 \
		smoll/jenkins:latest

clean-master:
	@docker kill jenkins-master || true
	@docker rm jenkins-master || true

# To manually rebuild this image without using cache (takes several minutes on my laptop), do:
# docker build -no-cache -t smoll/jenkins-nginx:latest nginx
nginx:
	@docker run -d \
		--name=jenkins-nginx \
		--link jenkins-master:jenkins-master \
		-p 80:80 -p 443:443 \
		smoll/jenkins-nginx:latest

clean-nginx:
	@docker kill jenkins-nginx || true
	@docker rm jenkins-nginx || true

# vagrant-based commands

slave:
	@cd slave; vagrant up

destroy:
	@cd slave; vagrant destroy -f

# convenient commands

logs:
	@docker logs -f jenkins-nginx

# Easier than typing
open:
	@open "https://`docker-machine ip default`"

# backup & restore data

# Doesn't let us restore due to owner issue; fix this
backup:
	@mkdir -p ./tmp
	@docker cp jenkins-master:/var/jenkins_home ./tmp/jenkins_home

.PHONY: build push purge data clean-data master clean nginx clean-nginx slave destroy logs open backup
