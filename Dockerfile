FROM centos:6

ENV LANG=en_US.UTF-8 TZ=Asia/Shanghai

# COPY etc/yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo
# COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
# COPY php-5.2.17_el6.x86_64.tar.gz /tmp
# COPY etc/init.d/php-fpm /etc/init.d/php-fpm
# COPY etc/nginx/conf.d/www.com.conf /etc/nginx/conf.d/www.com.conf
# COPY usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

COPY etc/yum.repos.d/nginx.repo etc/nginx/nginx.conf php-5.2.17_el6.x86_64.tar.gz etc/init.d/php-fpm etc/nginx/conf.d/www.com.conf usr/local/bin/docker-entrypoint.sh /tmp

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=https://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo && \
	mv /tmp/nginx.repo /etc/yum.repos.d/nginx.repo && \
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6 && \
	yum install -y epel-release && \
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 && \
	yum install -y nginx libmcrypt freetype mhash mysql-libs libtool-ltdl libpng gd libjpeg-turbo && \
	yum clean all && \
	tar xf /tmp/php-5.2.17_el6.x86_64.tar.gz -C /usr/local && \
	rm -f /tmp/php-5.2.17_el6.x86_64.tar.gz && \
	useradd --home-dir /usr/local/php-5.2.17/var/lib/php --create-home --user-group --shell /sbin/nologin --comment "PHP-FPM User" php && \
	chmod 750 /usr/local/php-5.2.17/var/lib/session/ && \
	chown php:php /usr/local/php-5.2.17/var/lib/session/ && \
	mv /tmp/php-fpm /etc/init.d/php-fpm && \
	mv /tmp/nginx.conf /etc/nginx/nginx.conf && \
	rm /etc/nginx/conf.d/* && \
	mv /tmp/www.com.conf /etc/nginx/conf.d/www.com.conf && \
	mkdir -p /var/www/html && \
	echo '<?php phpinfo(); ?>' > /var/www/html/index.php && \
	chown -R php:nginx /var/www/html && \
	mv /tmp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh && \
	chmod 755 /usr/local/bin/docker-entrypoint.sh /etc/init.d/php-fpm && \
	rm -fr /var/cache/yum/* /tmp/* /var/tmp/*


ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 80
