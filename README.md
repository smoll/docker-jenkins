# docker-jenkins
Dockerized Jenkins with CloudBees Docker Workflow

## What is this?
The [`jenkins`](https://github.com/jenkinsci/docker) Docker image from Docker Hub, plus a couple of plugins (Workflow et al.) to make it easy to:

* orchestrate the entire pipeline **(unit -> build Docker image -> acceptance -> deploy to Staging -> e2e)** using Docker with an easy-to-read DSL
* run builds on lightweight Jenkins slaves which only have Docker installed (not rbenv, pyvenv, etc.)
* run the exact same build locally on my laptop as we would on a shared CI server
* commit Jenkins job configs to source control, but ensuring that secrets and other special configurations aren't hidden in the job configs

## Usage
### Bootstrap
* Start all: `make`
* Clean all: `make clean`
* See [`Makefile`](./Makefile) for more.

Then, visit jenkins in the browser: https://dockerhostip (port 80 will also redirect to https://)

### Additional, manual steps
* Configure Jenkins to use LDAP for authorization (similar to [set_admin.groovy](master/set_admin.groovy), or [this script](https://github.com/blacklabelops/jenkins/blob/master/imagescripts/docker-entrypoint.sh).)
* Adding GitHub deploy key, as in [here](http://stackoverflow.com/a/33290122) or [here](https://cburgmer.wordpress.com/2013/01/02/tracking-configuration-changes-in-jenkins/).
* Set up Jenkins Swarm slave(s), like [this](https://github.com/carlossg/jenkins-swarm-slave-docker).

In the future, these could be automated, by setting an optional flag like `LDAP_SERVER=ldap.example.com` or `DEPLOY_KEY_PATH=/root/.ssh/id_rsa` (provided by volume mounting)

### *Optionally*

If you want to test nginx networking, edit your hosts file:
```
# /etc/hosts

192.168.99.100 jenkins.example.com
```

You should then be able to visit Jenkins at: https://jenkins.example.com

## TODOs
0. Automate build config from seed job(s) (Jenkins Job DSL Plugin) or at least put keep it in source control (SCM Sync Config Plugin). To figure out what to add to `plugins.txt`:
  * `docker exec -it CONTAINER_ID bash`
  * `grep -r "Short-Name: " /var/jenkins_home/plugins`
0. Automate SSH key-pairing with Jenkins slaves - see [this](http://stackoverflow.com/a/33290122).
0. Create `make backup` and `make restore` rules - see [this](http://aespinosa.github.io/blog/2014-03-05-import-jenkins-configuration-to-docker.html).
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
