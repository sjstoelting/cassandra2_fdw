#!/bin/bash

# Set variables
source ./build.cfg

# Function to check for a string is in another string
stringContains() { case $2 in *$1* ) return 0;; *) return 1;; esac ;}

# Validate input argument whether the result container should be removed
if [ "$1" = 1 ] || [ "$1" = "true" ] ; then
    REMOVE_RESULT_SERVER=true
    echo "Result server will be removed"
else
    REMOVE_RESULT_SERVER=false
fi # [ "$1" = 1 ] || [ "$1" = "true" ]


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
done # CASSANDRA_VERSION in "${CASSANDRA_VERSIONS[@]}"

## PostgreSQL
for PG_VERSION in "${POSTGRESQL_VERSIONS[@]}"
do
    # Set container names and PostgreSQL images
    POSTGRESQL_CONTAINER="POSTGRESQL_${PG_VERSION}_N"

    echo "Deleting container $POSTGRESQL_CONTAINER ..."
    sudo docker stop $POSTGRESQL_CONTAINER 2> /dev/null || true
    sudo docker rm $POSTGRESQL_CONTAINER 2> /dev/null || true
done # PG_VERSION in "${POSTGRESQL_VERSIONS[@]}"

# PostgreSQL result server
POSTGRESQL_RESULT_CONTAINER="POSTGRESQL_RESULT_${POSTGRESQL_RESULT_VERSION}_N"

if [ $REMOVE_RESULT_SERVER = true ]; then
    sudo docker stop $POSTGRESQL_RESULT_CONTAINER 2> /dev/null || true
    sudo docker rm $POSTGRESQL_RESULT_CONTAINER 2> /dev/null || true

    # Remove the network
    echo "Removing network $DOCKER_NETWORK ..."
    sudo docker network rm $DOCKER_NETWORK 2> /dev/null || true
fi # $REMOVE_RESULT_SERVER = true

DOCKER_NETWORK_CHECK=$(sudo docker ps --format '{{ .ID }} {{ .Names }} {{ json .Networks }}')

# Check if the Docker network is still up
if stringContains "$DOCKER_NETWORK" "$DOCKER_NETWORK_CHECK" && stringContains "$POSTGRESQL_RESULT_CONTAINER" "$DOCKER_NETWORK_CHECK"; then
    echo "Result container $POSTGRESQL_RESULT_CONTAINER and/or docker network $DOCKER_NETWORK are still up!"
else
    echo "Result container $POSTGRESQL_RESULT_CONTAINER and/or docker network $DOCKER_NETWORK have been removed"
fi # stringContains "$DOCKER_NETWORK" "$DOCKER_NETWORK_CHECK" && stringContains "$POSTGRESQL_RESULT_CONTAINER" "$DOCKER_NETWORK_CHECK"

echo ""
echo "Cleanup finished"
