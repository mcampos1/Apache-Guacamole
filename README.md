# Apache-Guacamole
Guacamole Deployment on AWS EC2
This readme describes how to deploy Guacamole via docker. It assumes an airgapped RHEL8 Linux environment.
For all binaries and docker images, please refer to the binary-locatons.md file.

Prerequisites
To deploy Guac, you'll need the following:

OS RPM repo ISO image (may not be needed, just in case)
Net-tools RPMs
Firewalld RPMs
Docker and Docker Compose RPMs
Guacamole client and server docker images
Postgres docker image
Nginx docker image
Docker compose file
Execution scripts


Instructions

Setup EC2 Instance (if using AWS)

Select RHEL 8.6 as your AMI
Select t2.xlarge as your instance type
Increase the base volume to 30 Gi
Add a volume with another 30 Gi (recommended)
Select the appropriate VPC and subnet if req'd in your environment
Configure a new Security Group with the following inbound rules:

type SSH, protocol TCP, port 22, source 0.0.0.0/0
type HTTP, protocol TCP, port 80, source 0.0.0.0/0
type HTTPS, protocol TCP, port 443, source 0.0.0.0/0
type PostgresSQL, protocol TCP, port 5432, source 0.0.0.0/0
type Custom TCP, protocol TCP, port 8080, source 0.0.0.0/0
type Custom TCP, protocol TCP, port 8443, source 0.0.0.0/0
type Custom TCP, protocol TCP, port 4822, source 0.0.0.0/0


Add the metadata tag Name and give the instance a name
Create or select an existing key for logging into the instance


Setup the OS RPM repo (if needed)

Determine your OS
$ cat /etc/redhat-release

Copy to the server where it is needed, example:
$ sudo scp -i <pem> rhel-server-8.X-x86_64-dvd.iso <server>:~/rhel-server-8.X-x86_64-dvd.iso

Log onto the server
$ ssh -i <pem> <user>@<ipaddress>

Mount the image on the server
$ mount -o loop rhel-server-7.8-x86_64-dvd.iso /mnt

Copy the repo locally
$ cp /mnt/media.repo /etc/yum.repos.d/rhel7dvd.repo
$ sudo chmod 644 /etc/yum.repos.d/rhel7dvd.repo

Edit the repo file via vi



Change the gpgcheck=0 parameter to 1
Add the following lines at the end:
enabled=1
baseurl=file:///mnt/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release



Clean the repos
$ sudo yum clean all && subscription-manager clean

Verify
$ sudo yum --noplugins list



Install Net-Tools

Copy to the server where it is needed, example:
$ sudo scp -i <pem> net-tools.rpm <server>:~/net-tools.rpm

Log onto the server
$ ssh -i <pem> <user>@<ipaddress>

Install the package
$ yum install ./<path>/net-tools.rpm



Install Firewalld

Copy to the server where it is needed, example:
$ sudo scp -i <pem> -r <path-to-rpms> <server>:~/<destpath>

Log onto the server
$ ssh -i <pem> <user>@<ipaddress>

Install the packages
$ yum install ./<destpath>/<path-to-rpms>/firewalld.rpm

Setup the firewall
$ sudo chmod +x ./<destpath>/<path-to-rpms>/setup-firewalld.sh
./<destpath>/<path-to-rpms>/setup-firewalld.sh



Install Docker and Docker Compose

Copy to the server where it is needed, example:
$ sudo scp -i <pem> -r <path-to-rpms> <server>:~/<destpath>

Log onto the server
$ ssh -i <pem> <user>@<ipaddress>

Install docker and docker compose via script
$ cd ./<destpath>/<path-to-rpms>
$ sudo chmod +x ./install-docker.sh
$ ./install-docker.sh

**important - Log off and back on to the server to enforce the changes
Make sure docker and docker compose is available:
$ docker version
$ docker compose version



Setup Images

Copy to the server where it is needed, example:
$ sudo scp -i <pem> -r <path-to-images> <server>:~/<destpath>

Log onto the server
$ ssh -i <pem> <user>@<ipaddress>

Import the images
$ docker load -i /path-to-images/postgres.13.4-buster.tar
$ docker load -i /path-to-images/guacamole-client-1.3.0.tar
$ docker load -i /path-to-images/guacamole-server-1.3.0.tar
$ docker load -i /path-to-images/nginx.tar



OR -
$ docker login docker.artifactory.dodiis.ic.gov -u <yourusername> -p <yourpassword>
$ docker pull docker.artifactory.dodiis.ic.gov/usstratcom/nec/ndmee/ironbank/guac/guacamole-client:1.4.0
$ docker pull docker.artifactory.dodiis.ic.gov/usstratcom/nec/ndmee/ironbank/guac/guacamole-server:1.4.0
$ docker pull docker.artifactory.dodiis.ic.gov/usstratcom/nec/ndmee/ironbank/postgres:13.6
$ docker pull docker.artifactory.dodiis.ic.gov/usstratcom/nec/ndmee/ironbank/nginx:1.23.2
$ docker logout docker.artifactory.dodiis.ic.gov



Verify the images
$ docker images



Prepare for Guacamole
This step creates the database, folders, and SSL cert/key. You can replace the cert/key with another, or modify the script to generate it as desired. 

Copy to the server where it is needed, example:
$ sudo scp -i <pem> -r <path-to-source> <server>:~/<destpath>

Log onto the server
$ ssh -i <pem> <user>@<ipaddress>

Make sure the scripts are executable (you may also want to chown)
$ cd /dest-path/scripts
$ sudo chmod +x ./prepare.sh
$ sudo chmod +x ./startup.sh
$ sudo chmod +x ./reset.sh

Create the database and ssl cert
$ ./prepare.sh



Run the Guacamole containerss

Log onto the server
$ ssh -i <pem> <user>@<ipaddress>

Use the startup script to fire up the swarm
$ cd /dest-path/scripts
$ ./startup.sh

Verify things are running:
$ docker ps -a

Use to the following to troubleshoot failing containers:
$ docker logs -f <containerid>

If all is well, verify browsing (usually from the jump box (bastion)
Go to https://<ipaddress>:8443



Cleanup Instructions
This is provided to reset the environment before reattempting 'Run the Guacamole containers'.
It will remove the database, SSL key/cert, etc.

Log onto the server
$ ssh -i <pem> <user>@<ipaddress>

Stop containers and reset via the stop.sh script.
$ cd /dest-path/scripts
$ ./reset.sh



Additional Resources

https://gitlab.code.dicelab.net/robert.s.sommerville/guacamole-via-docker
https://github.com/boschkundendienst/guacamole-docker-compose
https://gitlab.code.dicelab.net/andrew.j.caulkins/admiral-demo
https://docs.docker.com/compose/install/
https://docs.docker.com/engine/install/
https://nathancatania.com/posts/installing-docker-on-red-hat-with-no-internet-access/
