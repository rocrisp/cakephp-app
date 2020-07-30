
cakephp-app
======================

This is a quickstart Dockerfile for deploying CakePHP in a Docker container, able to connect to a remote database, and inject ENV vars to configure your application.

**Note: The CakePHP application is forked from [here](https://github.com/sclorg/cakephp-ex).**

Based on Centos 7 and PHP 7.3

**Note: This project is meant to be an example to study the basics and essentials of Kubernetes Operators using the Openshift platfrom with the CakePHP application in a Docker environment, therefore it is build on an Centos base image rather then a PHP base image.**

Usage
-----
To create the image `quay.io/rocrisp/cakedemo`, execute the following command on the cakephp-app directory:
**Note: Replace quay.io/rocrisp with your own registry.**

```bash
docker build --no-cache -t quay.io/rocrisp/cakedemo:v1 .
```

Openshift Operator requires the image to pull from a registry.
You can now push your new image to a registry:

```bash
docker push quay.io/rocrisp/cakedemo
```

Running your CakePHP docker image
-----------------------------------

1: Connecting to a MySQL container
-----------------------------------
Start a [MySQL container](https://hub.docker.com/_/mysql/) 

```bash
docker run -d \
	--name mysql-server \
	-e MYSQL_ROOT_PASSWORD=cakephp \
	-e MYSQL_DATABASE=cakephp \
	mysql:5.7
```
2: Running your CakePHP docker image and and link it to the MySQL container you just started.
-----------------------------------

```bash
docker run -d -p 80:8080 \
	--name cakephp \
	-e "DATABASE_URL=mysql://root:cakephp@mysql-server/cakephp?encoding=utf8&timezone=UTC&cacheMetadata=true" \
	-e "SESSION_DEFAULTS=database" \
	-e "DATABASE_NAME=cakephp" \
	-e "FIRST_LASTNAME=Rose Crisp" \
	--link mysql-server:mysql \
	quay.io/rocrisp/cakedemo:v1
```

Test your deployment
--------------------------

Visit `http://localhost/` in your browser or 

	curl http://localhost/

You can now start using your CakePHP container!


Troubleshooting
-------------------------


If you get this error: Bind for 0.0.0.0:80 failed: port is already allocated.

```bash
docker ps -a | grep 80
docker rm -f <container id >
```
