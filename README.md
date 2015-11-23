# docker-jenkins
Dockerized Jenkins with CloudBees Docker Workflow

## What is this?
The [`jenkins`](https://github.com/jenkinsci/docker) Docker image from Docker Hub, plus a couple of plugins (Workflow et al.) to make it easy to:

* orchestrate builds using Docker with an easy-to-read DSL
* run builds on lightweight Jenkins slaves which only have Docker installed (not rbenv, pyvenv, etc.)
* run the exact same build locally on my laptop as we would on a shared CI server
* commit Jenkins job configs to source control, but ensuring that secrets and other special configurations aren't hidden in the job configs

## Usage
Create the data-only container
```
make data
```

Create the jenkins master
```
make master
```

Visit Jenkins in the browser

* Linux host: [http://localhost:8080](http://localhost:8080)

* Mac host: do `docker-machine ip default` or `boot2docker ip`, for me it's http://192.168.99.100:8080

## TODOs
0. Automate build config (Add Jenkins Job DSL or SCM Sync Config Plugin, first). To figure out what to add to `plugins.txt`:
  * `docker exec -it CONTAINER_ID bash`
  * `grep -r "Short-Name: " /var/jenkins_home/plugins`
0. Add NGINX to make it easier for slaves to connect to master
0. Automate SSH key-pairing with Jenkins slaves
0. Control data-only container via Docker Compose (maybe?)

## Old Approach
Based on my findings from [smoll/docker-jenkins-dood](https://github.com/smoll/docker-jenkins-dood), I realized that even if locally we are able to orchestrate containers as they were children (when they are actually siblings), we still run into a networking problem, namely, ambiguity around `localhost`.

For example, with non-DooD Jenkins, this Workflow script runs successfully:

```groovy
node('docker') {
    docker.image('tutum/hello-world').withRun('-p 8181:80') {c ->
    	// These commands are being run on the node, not the container
        sh "sleep 3"
        sh "curl http://localhost:8181/"
    }
}
```

However, when the same script is run with DooD Jenkins, it spins up the container correctly, but the `curl` fails because if we're using a Docker Machine VM (boot2docker) on a Mac, `localhost` is the Mac, but the application is actually listening on the VM, i.e. `$(docker-machine ip default):8181`

## New Approach
Run Jenkins master in a container (non-DooD), and for slaves,

* locally: attach a Vagrant-based Docker node
* shared CI: attach generic cloud-based (EC2, or w/e) Docker node(s)

Still unsure of how to automate SSH key-pair installation on the Jenkins master and multiple slaves (perhaps Docker Machine can help?), so this part is still manual for now.

## References
0. Docker Compose with NGINX reverse proxy and data-only container - https://engineering.riotgames.com/news/jenkins-docker-proxies-and-compose
0. Dockerfile with SSH creds - https://issues.jenkins-ci.org/browse/JENKINS-25153
0. Jenkins slave using Swarm client - http://tombee.co.uk/2014/10/31/docker-jenkins-slaves-with-swarm-and-shipyard/
0. Interesting: using Dev laptops as Jenkins slaves using Swarm - https://zwischenzugs.wordpress.com/2015/03/19/scale-your-jenkins-compute-with-your-dev-team-use-docker-and-jenkins-swarm/
