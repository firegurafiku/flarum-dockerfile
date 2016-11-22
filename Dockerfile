FROM ubuntu:14.04
MAINTAINER Pavel Kretov <firegurafiku@gmail.com>

# Exact package versions to be fetched from the Packagist.
ARG flarumPackage="flarum/flarum:v0.1.0-beta.6"
ARG flarumExtPackages="\
       flagrow/upload:0.3.2 \
       flagrow/flarum-ext-latex:0.1.1 \
       sijad/flarum-ext-github-autolink:0.1.1-beta.1 \
       sijad/flarum-ext-links:0.1.0-beta.6 \
       sijad/flarum-ext-pages:0.1.0-beta.3 \
       csi/flarum-ext-russian:0.1.0-beta.5-1 \
       jordanjay29/flarum-ext-summaries:0.2.0"

# Where exactly to download Composer installer from.
ARG flarumComposerHash="1b137f8bf6db3e79a38a5bc45324414a6b1f9df2"
ARG flarumComposerUrl="https://raw.githubusercontent.com/composer/getcomposer.org/$flarumComposerHash/web/installer"

# Flarum user is going to own all PHP code on the filesystem, to make it
# unwritable by the web-server.
ARG flarumUser="flarum"
ARG flarumDir="/srv/flarum"
ARG flarumSocket="/var/run/php5-fpm.sock"

# Duplicate the ARGs above as environment variables to make them accessible
# when the container is run for its first time. We are going to need this
# data to generate proper configuration files.
ENV flarumUser="$flarumUser"
ENV flarumDir="$flarumDir"
ENV flarumSocket="$flarumSocket"

# Below lines are configuration variables available to end users. Note that
# flarumAdmin* variables are only meaningful if flarumPerformInstall=="yes".
ENV flarumHostname="localhost"
ENV flarumDbHost="localhost"
ENV flarumDbPort="3306"
ENV flarumDbName="flarum"
ENV flarumDbUser="flarum"
ENV flarumDbPass="flarum"
ENV flarumDbPrefix=""

ENV flarumPerformInstall="no"
ENV flarumAdminName="admin"
ENV flarumAdminEmail="admin@localhost"
ENV flarumAdminPass=""

# Let Nginx shine.
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

USER "$flarumUser"

RUN cd "$flarumDir" \
    && wget "$flarumComposerUrl" -O- -q | php5 -- --quiet \
    && php5 composer.phar create-project "$flarumPackage" app \
    && cd ./app \
    && php5 ../composer.phar require $flarumExtPackages \
    && php5 ../composer.phar dumpautoload --optimize

USER root

ADD fpm-flarum.conf                /.attach/
ADD nginx.conf                     /.attach/
ADD nginx-flarum.conf              /.attach/
ADD flarum-config.php              /.attach/
ADD flarum-unattended-install.yml  /.attach/
ADD run-container.sh               /

RUN chmod +x /run-container.sh \
    && chown $flarumUser:www-data -R $flarumDir/app \
    && chmod 775 $flarumDir/app/assets \
    && chmod 775 -R $flarumDir/app/storage

# Perform some aggressive cleanup.
RUN apt-get remove -y git wget \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["$flarumDir/app/assets"]

CMD /run-container.sh
