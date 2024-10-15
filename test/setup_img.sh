#!/bin/bash

# Set variables
source ./build.cfg

# Create the network
sudo docker network create --driver bridge $DOCKER_NETWORK || true

# Setup PostgreSQL containers
./setup_pg.sh

# Setup Cassandra containers
./setup_cas.sh
