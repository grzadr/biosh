#!/bin/bash

# Basic commands to clear exited containers and clear dangling images

# Removes exited containers
docker container prune -f

# Removes dangling images
docker images -qf dangling=true | xargs --no-run-if-empty docker rmi
