#!/bin/bash
# Start the test services in the background so they come up while
# the rest of the job sets up. Run wait-for-services.sh before using them.
#
# Images are loaded from ~/docker-images when the cache has them there,
# which is faster than pulling them from Docker Hub.
set -e

localstack=$(jq -r '.localstack' .dockerimages.json)
opensearch=$(jq -r '.opensearch' .dockerimages.json)

mkdir -p /tmp/services

# Usage: start <name> <image> "<docker run options>" ["<container command args>"]
start() {
  local name=$1 image=$2 options=$3 args=$4
  local cached=~/docker-images/$name.tar
  nohup bash -c "
    [ -f $cached ] && docker load -q -i $cached
    docker run -d --name $name $options $image $args
  " > "/tmp/services/$name.log" 2>&1 &
}

# The data lives in memory and skips durability, as it's thrown away with the job
start mysql mysql:5.7 \
  "-p 3306:3306 --tmpfs /var/lib/mysql -e MYSQL_USER=exercism -e MYSQL_PASSWORD=exercism -e MYSQL_DATABASE=exercism_test -e MYSQL_ROOT_PASSWORD=password" \
  "--innodb-flush-log-at-trx-commit=0 --innodb-doublewrite=0 --sync-binlog=0 --skip-name-resolve --innodb-log-file-size=8M"
start redis redis:7 "-p 6379:6379"
start aws "$localstack" "-p 4566:4566"
start opensearch "$opensearch" "-p 9200:9200 -e discovery.type=single-node"
