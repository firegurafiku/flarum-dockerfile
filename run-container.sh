#!/bin/sh
set -o nounset
set -o errexit

if [ ! -f /.container_configuration_done ] ; then
    envsubst </.attach/fpm-flarum.conf >/etc/php5/fpm/pool.d/flarum.conf
    envsubst </.attach/nginx.conf      >/etc/nginx.conf
    envsubst '$flarumHostname $flarumDir $flarumSocket' \
	     </.attach/nginx-flarum.conf \
             >/etc/nginx/sites-available/flarum.conf
    ln -s /etc/nginx/sites-available/flarum.conf \
          /etc/nginx/sites-enabled/

    rm /etc/nginx/sites-enabled/default
    rm /etc/php5/fpm/pool.d/www.conf

    if [ "$flarumPerformInstall" = "yes" ] ; then
	# Check if all required variables are set (in 'nounset' we trust).
	: "$flarumAdminName $flarumAdminEmail $flarumAdminPass"
	
        sudo -u "$flarumUser" --preserve-env -- sh -c '
            set -o errexit
            cd $flarumDir/app
            envsubst </.attach/flarum-unattended-install.yml >install-config.yml
            php5 flarum install -f install-config.yml'
    else
        sudo -u "$flarumUser" --preserve-env -- sh -c '
            set -o errexit
            cd $flarumDir/app
            envsubst </.attach/flarum-config.php >config.php
            php5 flarum migrate
            cp -r vendor/components/font-awesome/fonts assets/'
    fi
    
    touch /.container_configuration_done
fi

php5-fpm # Will daemonize itself
exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
