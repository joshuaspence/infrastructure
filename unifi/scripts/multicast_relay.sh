#!/bin/sh

set -e
set -u
set -o pipefail

CONTAINER_NAME='multicast-relay'
IMAGE_NAME='scyto/multicast-relay'

. /etc/default/multicast-relay

case "${1:-start}" in
  start)
    podman rm --force "${CONTAINER_NAME}" &>/dev/null || true
    podman run --detach --env "INTERFACES=${INTERFACES}" --env "OPTS=--relay ${RELAY} --noMDNS --noSSDP --noSonosDiscovery --verbose" --name "${CONTAINER_NAME}" --network host --restart always "${IMAGE_NAME}:${IMAGE_TAG:-latest}"
    ;;

  stop)
    podman stop "${CONTAINER_NAME}"
    ;;

  restart)
    $0 status && $0 stop || true
    $0 start
    ;;

  status)
    test -n "$(podman ps --filter "name=${CONTAINER_NAME}" --filter status=running --quiet)"
    ;;

  *)
	  echo "Usage: $0 {start|stop|restart|status}"
	  exit 1
esac
