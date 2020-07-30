FROM centos:7

LABEL maintainer="Rose Crisp <rocrisp@redhat.com>"

EXPOSE 8080
EXPOSE 8443

# Install Apache
RUN yum -y update && \
    yum -y install httpd httpd-tools && \
	mkdir -p /run/httpd/ && \
	chown -R root:root /run/httpd && \
	chmod a+rw /run/httpd && \
	chmod go+rwx /var/log/httpd

# Install EPEL Repo
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm

# Install PHP
RUN yum --enablerepo=remi-php73 -y install unzip git php php-bcmath php-cli php-common php-gd php-intl php-ldap php-mbstring \
    php-mysqlnd php-pear php-soap php-xml php-xmlrpc php-zip phy-lib-ICU 

RUN  curl -sS https://getcomposer.org/installer | php
RUN  mv composer.phar /usr/local/bin/composer
RUN  chmod +x /usr/local/bin/composer
COPY apache_default /etc/httpd/conf.d/httpd.conf
	
# Update Apache Configuration
RUN sed -E -i -e '/<Directory "\/var\/www\/html">/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
RUN sed -E -i -e 's/DirectoryIndex (.*)$/DirectoryIndex index.php \1/g' /etc/httpd/conf/httpd.conf
RUN sed -E -i -e 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
RUN sed -E -i -e 's/ServerName www.example.com:80/ServerName localhost:8080/g' /etc/httpd/conf/httpd.conf

################################################################
# Example, deploy a default CakePHP 3 installation from source #
################################################################

# Clone your application (cloning CakePHP 3 / app instead of composer create project to demonstrate application deployment example)
RUN rm -rf /var/www/html
ADD cakephp /var/www/html

# Set workdir (no more cd from now)
WORKDIR /var/www/html

# Composer install application
RUN composer -n install
RUN chmod a+rwx /var/www/html/logs
RUN chmod -R a+rwx /var/www/html/tmp

# # Inject some non random salt for this example
RUN sed -i -e "s/__SALT__/somerandomsalt/" config/app.php && \
	# Make sessionhandler configurable via environment
	sed -i -e "s/'php',/env('SESSION_DEFAULTS', 'php'),/" config/app.php
	# Set write permissions for webserver
RUN rm -rf /run/httpd/* /tmp/httpd*
# Start Apache
CMD ["/usr/sbin/httpd","-DFOREGROUND"]
