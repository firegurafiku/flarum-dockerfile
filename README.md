Dockerized Flarum with Russian localization
===========================================

This repository contains a Dockerfile for building [firegurafiku/flarum][1]
image. It's an attempt to containerize Flarum forum application (written in
modern PHP) and a bunch of its extensions with Nginx, PHP-FPM and everything
else which is required for the forum to run (except a database server).

[1]: https://hub.docker.com/r/firegurafiku/flarum/

Example deploy
--------------

You don't have to rebuild anything from source if you want to deploy
an unmodified image. Just pull one from DockerHub, as well as a MariaDB
instance. You may use the following script to get a running forum in
seconds, but don't forget to adjust your settings:

    #!/bin/sh
    set -o nounset
    set -o errexit

    # --- Adjust options here. ---
    # Please, avoid using backslashes and quotes in these variables,
    # or envsubst-based templating may fail. You should really adjust
    # only the "<here>" entries.
    networkName="flarum-network"
    mariadbContainerName="flarum-mariadb"
    mariadbDatabaseName="flarum"
    mariadbDatabaseUser="flarum"
    mariadbDatabasePass="<here>"
    flarumContainerName="flarum"
    flarumHostname="localhost"
    flarumPerformInstall="yes"
    flarumDatabasePrefix=""
    flarumAdminName="admin"
    flarumAdminEmail="admin@localhost.localdomain"
    flarumAdminPass="<here>"

    # --- Let's go. ---

    sudo docker network create "$networkName"

    sudo docker run \
        -e MYSQL_DATABASE="$mariadbDatabaseName" \
        -e MYSQL_USER="$mariadbDatabaseUser" \
        -e MYSQL_PASSWORD="$mariadbDatabasePass" \
        -e MYSQL_ROOT_PASSWORD="$mariadbDatabasePass" \
        --net="$networkName" \
        --net-alias="$mariadbContainerName" \
        --name "$mariadbContainerName" \
        --detach \
                mariadb

    echo "Waiting for MariaDB to initialize (30 sec)..."
    sleep 30s

    sudo docker run \
        -e flarumPerformInstall="$flarumPerformInstall" \
        -e flarumDbHost="$mariadbContainerName" \
        -e flarumDbName="$mariadbDatabaseName" \
        -e flarumDbUser="$mariadbDatabaseUser" \
        -e flarumDbPass="$mariadbDatabasePass" \
        -e flarumHostname="$flarumHostname" \
        -e flarumDbPrefix="$flarumDatabasePrefix" \
        -e flarumAdminName="$flarumAdminName" \
        -e flarumAdminEmail="$flarumAdminEmail" \
        -e flarumAdminPass="$flarumAdminPass" \
        --net="$networkName" \
        --net-alias="$flarumContainerName" \
        --name="$flarumContainerName" \
        --publish 80:80 \
        --detach \
            firegurafiku/flarum
