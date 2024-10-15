#!/bin/bash

# Setting up PostgreSQL containers

# Set variables
source ./build.cfg

# PostgreSQL
for PG_VERSION in "${POSTGRESQL_VERSIONS[@]}"
do
    # Set container names and PostgreSQL images
    POSTGRESQL_CONTAINER="POSTGRESQL_${PG_VERSION}_N"
    POSTGRESQL_IMAGE="postgres:${PG_VERSION}"

    ## Create the container
    echo "Creating container $POSTGRESQL_CONTAINER ..."
    sudo docker run -d --name $POSTGRESQL_CONTAINER --network $DOCKER_NETWORK -e POSTGRES_USER=$POSTGRESQL_USER -e POSTGRES_PASSWORD=$POSTGRESQL_PWD -e POSTGRES_DB=$POSTGRESQL_USER -d ${POSTGRESQL_IMAGE}

    sudo docker start $POSTGRESQL_CONTAINER

    echo "PostgreSQL text container: $POSTGRESQL_CONTAINER"

    ## Update packages
    sudo docker exec -it $POSTGRESQL_CONTAINER bash -c "apt-get update > /dev/null; apt-get upgrade -y > /dev/null"

    ## Install additional packages for the cpp-driver and PostgreSQL
    sudo docker exec -it $POSTGRESQL_CONTAINER bash -c "apt-get install locales-all locales -y > /dev/null"
    sudo docker exec -it $POSTGRESQL_CONTAINER bash -c "apt-get install git make cmake build-essential lsb-release wget libuv1 libuv1-dev openssl libssl-dev zlib1g-dev zlib1g libkrb5-dev wget pgxnclient postgresql-contrib postgresql-server-dev-${PG_VERSION} -y > /dev/null"

    ## Get the cpp-driver sources
    sudo docker exec -it $POSTGRESQL_CONTAINER bash -c "mkdir /tmp ; cd /tmp ; git clone https://github.com/datastax/cpp-driver.git"

    ## Compile and install the ccp-driver
    sudo docker exec -it $POSTGRESQL_CONTAINER bash -c "cd /tmp/cpp-driver ; mkdir build ; pushd build ; cmake .. ; make ; make install ; popd"

    ## Copy the cassandra2_fdw sources into the container
    sudo docker cp ../../cassandra2_fdw $POSTGRESQL_CONTAINER:/tmp

    ## Change pg_config to use the right version in the Makefile
    CONFIGFILE="\"\/usr\/lib\/postgresql\/${PG_VERSION}\/bin\/pg_config\""

    sudo docker exec -it $POSTGRESQL_CONTAINER bash -c "cd /tmp/cassandra2_fdw ; sed -i 's/pg_config/${CONFIGFILE}/g' Makefile"

    ## Compile the cassandra2_fdw
    sudo docker exec -it $POSTGRESQL_CONTAINER bash -c "cd /tmp/cassandra2_fdw ; USE_PGXS=1 make ; USE_PGXS=1 make install"

    ## Update libraries
    sudo docker exec -it $POSTGRESQL_CONTAINER bash -c "ldconfig"

done
