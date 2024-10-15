#!/bin/bash

# Set variables
source ./build.cfg

# Create the network
sudo docker network create --driver bridge $DOCKER_NETWORK || true

# Setup the PostgreSQL container where the test results are stored
./setup_res.sh

# Setup PostgreSQL containers
./setup_pg.sh

# Setup Cassandra containers
./setup_cas.sh
