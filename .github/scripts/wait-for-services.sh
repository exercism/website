#!/bin/bash
# Block until every service started by start-services.sh is accepting connections.

wait_for() {
  local name=$1; shift
  for _ in $(seq 1 180); do
    if "$@" > /dev/null 2>&1; then
      echo "$name is ready"
      return 0
    fi
    sleep 1
  done
  echo "$name did not become ready"
  cat "/tmp/services/$name.log"
  docker logs "$name" 2>&1 | tail -50
  exit 1
}

wait_for mysql docker exec mysql mysqladmin ping -h 127.0.0.1 -uroot -ppassword --silent
wait_for redis docker exec redis redis-cli ping
wait_for aws curl --fail --silent http://127.0.0.1:4566/_localstack/health
wait_for opensearch curl --fail --silent --insecure --user admin:admin "https://127.0.0.1:9200/_cluster/health?wait_for_status=yellow&timeout=1s"
