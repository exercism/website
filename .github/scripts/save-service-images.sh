#!/bin/bash
# Save the service images to ~/docker-images so the cache can store them
# for start-services.sh to load in later jobs.
set -e

mkdir -p ~/docker-images
for name in mysql redis aws opensearch; do
  docker save -o ~/docker-images/$name.tar "$(docker inspect --format '{{.Config.Image}}' $name)"
done
du -sh ~/docker-images/*
