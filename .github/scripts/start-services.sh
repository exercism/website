#!/bin/bash
# Start the test services in the background so their images pull in parallel
# while the rest of the job sets up. Run wait-for-services.sh before using them.
set -e

localstack=$(jq -r '.localstack' .dockerimages.json)
opensearch=$(jq -r '.opensearch' .dockerimages.json)

mkdir -p /tmp/services
start() {
  local name=$1; shift
  nohup docker run -d --name "$name" "$@" > "/tmp/services/$name.log" 2>&1 &
}

start mysql -p 3306:3306 \
  -e MYSQL_USER=exercism -e MYSQL_PASSWORD=exercism \
  -e MYSQL_DATABASE=exercism_test -e MYSQL_ROOT_PASSWORD=password \
  mysql:5.7
start redis -p 6379:6379 redis
start aws -p 4566:4566 "$localstack"
start opensearch -p 9200:9200 -e discovery.type=single-node "$opensearch"
