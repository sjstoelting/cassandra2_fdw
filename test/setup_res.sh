#!/bin/bash

# Setting up PostgreSQL result containers

# Set variables
source ./build.cfg

# Function to check for a string is in another string
stringContains() { case $2 in *$1* ) return 0;; *) return 1;; esac ;}

# PostgreSQL
POSTGRESQL_RESULT_CONTAINER="POSTGRESQL_RESULT_${POSTGRESQL_RESULT_VERSION}_N"

DOCKER_NETWORK_CHECK=$(sudo docker ps -a --format '{{ .ID }} {{ .Names }} {{ json .Networks }}')

## Only create the container, if it does not alread exist
if stringContains "$POSTGRESQL_RESULT_CONTAINER" "$DOCKER_NETWORK_CHECK"; then
    # As the result container already exists, as it might be down, it will be started
    sudo docker start $POSTGRESQL_RESULT_CONTAINER > /dev/null || true
    echo "Result container $POSTGRESQL_RESULT_CONTAINER is already up"
else
    POSTGRESQL_RESULT_IMAGE="postgres:${POSTGRESQL_RESULT_VERSION}"

    ## Create the result container as it does not exist
    echo "Creating container $POSTGRESQL_RESULT_CONTAINER ..."
    sudo docker run -d --name $POSTGRESQL_RESULT_CONTAINER --network $DOCKER_NETWORK -e POSTGRES_USER=$POSTGRESQL_USER -e POSTGRES_PASSWORD=$POSTGRESQL_PWD -e POSTGRES_DB=$POSTGRESQL_USER -d ${POSTGRESQL_RESULT_IMAGE}
    sudo docker start $POSTGRESQL_RESULT_CONTAINER

    ## Wait for five seconds to be sure, that PostgreSQL is up and running
    echo "Waiting for five seconds until PostgreSQL is up in $POSTGRESQL_RESULT_CONTAINER ..."
    sleep 5

    sudo docker exec -it $POSTGRESQL_RESULT_CONTAINER psql --host=$POSTGRESQL_HOST --port=$POSTGRESQL_PORT --username=$POSTGRESQL_USER $POSTGRESQL_DB1 --command "DROP DATABASE IF EXISTS $POSTGRESQL_RESULT_DB;"
    sudo docker exec -it $POSTGRESQL_RESULT_CONTAINER psql --host=$POSTGRESQL_HOST --port=$POSTGRESQL_PORT --username=$POSTGRESQL_USER $POSTGRESQL_DB1 --command "CREATE DATABASE $POSTGRESQL_RESULT_DB;"
    sudo docker exec -it $POSTGRESQL_RESULT_CONTAINER psql --host=$POSTGRESQL_HOST --port=$POSTGRESQL_PORT --username=$POSTGRESQL_USER $POSTGRESQL_RESULT_DB --command "CREATE SCHEMA $POSTGRESQL_RESULT_SCHEMA;"

    sudo docker exec -it $POSTGRESQL_RESULT_CONTAINER psql --host=$POSTGRESQL_HOST --port=$POSTGRESQL_PORT --username=$POSTGRESQL_USER $POSTGRESQL_RESULT_DB --command "CREATE TABLE $POSTGRESQL_RESULT_SCHEMA.results (created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp, postgresql_version TEXT NOT NULL, cassandra_version TEXT NOT NULL, test_description TEXT NOT NULL, test_result TEXT NOT NULL);"

    echo "Result container $POSTGRESQL_RESULT_CONTAINER created"
fi # stringContains "$POSTGRESQL_RESULT_CONTAINER" "$DOCKER_NETWORK_CHECK"
