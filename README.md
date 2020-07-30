
cakephp-app
======================

This is a quickstart Dockerfile for deploying CakePHP in a Docker container, able to connect to a remote database, and inject ENV vars to configure your application.

**Note: The CakePHP application is forked from [here](https://github.com/sclorg/cakephp-ex) 

Based on Centos 7 and PHP 7.3

**Note: This project is meant to be an example to study the basics and essentials of Kubernetes Operators using the Openshift platfrom with the CakePHP application in a Docker environment, therefore it is build on an Centos base image rather then a PHP base image, uses a 'simple' webserver like Apache and has some non-efficient commands to demonstrate stuff.**

Usage
-----

You can edit the `Dockerfile` to add your own git, composer or custom commands to add your application code to the image.

To create the image `quay.io/rocrisp/cakedemo`, execute the following command on the cakephp-app directory:

```bash
docker build --no-cache -t quay.io/rocrisp/cakedemo:v1 .
```
Replace quay.io/rocrisp with your own registry

requirement: You can now push your new image to a registry:

```bash
docker push quay.io/rocrisp/cakedemo
```

Running your CakePHP docker image
-----------------------------------

Start your image forwarding container port 8080 to localhost port 80:

```bash
docker run -d -p 80:8080 quay.io/rocrisp/cakedemo:v1
```

If you get this error: Bind for 0.0.0.0:80 failed: port is already allocated.

```bash
docker ps -a | grep 80
docker rm -f <container id >
```

Example: Connecting to a MySQL container
-----------------------------------
Start a [MySQL container](https://hub.docker.com/_/mysql/) 

```bash
docker run -d \
	--name mysql-server \
	-e MYSQL_ROOT_PASSWORD=cakephp \
	-e MYSQL_DATABASE=cakephp \
	mysql:5.7
```

Start your image and:
* Link it to the MySQL container you just started (so your container can contact it)
* Connect to a remote database server using the CakePHP DATABASE_URL env variable filled with the variables given in the command above.
* Use the `database` session handler using our the SESSION_DEFAULTS env variable (see `Dockerfile` for implementation)

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
