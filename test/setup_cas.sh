#!/bin/bash

# Setting up Cassandra containers

# Set variables
source ./build.cfg

# Cassandra
for CASSANDRA_VERSION in "${CASSANDRA_VERSIONS[@]}"
do
    # Set container name and image
    CASSANDRA_CONTAINER="Cassandra_${CASSANDRA_VERSION}_N"
    CASSANDRA_CONTAINER=${CASSANDRA_CONTAINER/./_}
    echo "Cassandra container: $CASSANDRA_CONTAINER"

    CASSNADRA_IMAGE="cassandra:$CASSANDRA_VERSION"

    # Creating and starting the cassandra container
    echo "Creating container $CASSANDRA_CONTAINER from $CASSNADRA_IMAGE ..."
    sudo docker run --name $CASSANDRA_CONTAINER --network $DOCKER_NETWORK -d "cassandra:$CASSANDRA_VERSION"

done

# Cassandra needs some time to be started, therefore the script waits for 30 seconds
echo "Waiting for 60 seconds until Cassandra servers have started and are up..."
sleep 60
