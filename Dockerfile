FROM ubuntu:14.04
MAINTAINER Pavel Kretov <firegurafiku@gmail.com>

ARG flarumUser="flarum"
ARG flarumGroup="flarum"
ARG flarumDir="/srv/flarum"
ARG flarumStaticDir="/srv/flarum-static"
ARG flarumUploadsDir="/srv/flarum-uploads"
ARG flarumComposerHash="1b137f8bf6db3e79a38a5bc45324414a6b1f9df2"
ARG flarumComposerUrl="https://raw.githubusercontent.com/composer/getcomposer.org/$flarumComposerHash/web/installer"

ENV flarumHostname="localhost"
ENV flarumDbHost="localhost"
ENV flarumDbPort="3306"
ENV flarumDbName="flarum"
ENV flarumDbUser="flarum"
ENV flarumDbPass="flarum"
ENV flarumDbPrefix=""

ENV flarumPerformInstall="no"
ENV flarumAdminName=""
ENV flarumAdminEmail=""
ENV flarumAdminPass=""

EXPOSE 80

USER root
RUN apt-get update
RUN apt-get install -y \
        gettext \
        wget \
	nginx \
        git \
        php-pear \
        php5-cgi \
        php5-cli \
        php5-common \
        php5-curl \
        php5-fpm \
        php5-gd \
        php5-mcrypt \
        php5-mysql

RUN useradd --create-home --home-dir="$flarumDir" "$flarumUser"
RUN chown "$flarumUser":www-data "$flarumDir"

USER ${flarumUser}
RUN cd "$flarumDir" \
    && wget "$flarumComposerUrl" -O- -q | php5 -- --quiet \
    && php5 composer.phar create-project flarum/flarum app --stability=beta

USER root

ARG flarumSocket="/var/run/php5-fpm.sock"
ENV flarumDir="$flarumDir"
ENV flarumSocket="$flarumSocket"

ADD fpm-flarum.conf    /.attach/
ADD nginx.conf         /.attach/
ADD nginx-flarum.conf  /.attach/
ADD flarum-config.php  /.attach/
ADD flarum-unattended-install.yml  /.attach/
ADD run-container.sh   /

RUN chmod +x /run-container.sh \
    && chown $flarumUser:www-data -R $flarumDir/app \
    && chmod 775 $flarumDir/app/assets \
    && chmod 775 -R $flarumDir/app/storage

CMD /run-container.sh
