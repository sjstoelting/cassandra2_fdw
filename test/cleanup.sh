#!/bin/bash

# Set variables
source ./build.cfg

# Get the IP address of the Cassandra server
if [ -z "$1" ]; then
    REMOVE_RESULT_SERVER=0
else
    REMOVE_RESULT_SERVER=1
fi

# Remove containers
## Cassandra
for CASSANDRA_VERSION in "${CASSANDRA_VERSIONS[@]}"
do
    # Set container name and image
    CASSANDRA_CONTAINER="Cassandra_${CASSANDRA_VERSION}_N"
    CASSANDRA_CONTAINER=${CASSANDRA_CONTAINER/./_}

    # Deleting the cassandra container
    echo "Deleting container $CASSANDRA_CONTAINER ..."
    sudo docker stop $CASSANDRA_CONTAINER 2> /dev/null || true
    sudo docker rm $CASSANDRA_CONTAINER 2> /dev/null || true
done

## PostgreSQL
for PG_VERSION in "${POSTGRESQL_VERSIONS[@]}"
do
    # Set container names and PostgreSQL images
    POSTGRESQL_CONTAINER="POSTGRESQL_${PG_VERSION}_N"

    echo "Deleting container $POSTGRESQL_CONTAINER ..."
    sudo docker stop $POSTGRESQL_CONTAINER 2> /dev/null || true
    sudo docker rm $POSTGRESQL_CONTAINER 2> /dev/null || true
done

# PostgreSQL result server
if [ $REMOVE_RESULT_SERVER -eq 1 ]; then
    POSTGRESQL_RESULT_CONTAINER="POSTGRESQL_RESULT_${POSTGRESQL_RESULT_VERSION}_N"
    sudo docker stop $POSTGRESQL_RESULT_CONTAINER 2> /dev/null || true
    sudo docker rm $POSTGRESQL_RESULT_CONTAINER 2> /dev/null || true

    # Remove the network
    echo "Removing network $DOCKER_NETWORK ..."
    sudo docker network rm $DOCKER_NETWORK 2> /dev/null || true

    echo "Result container $POSTGRESQL_RESULT_CONTAINER and docker network $DOCKER_NETWORK have been removed"
else
    echo "Result container $POSTGRESQL_RESULT_CONTAINER and docker network $DOCKER_NETWORK are still up!"
fi
