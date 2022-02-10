#!/bin/vbash

set -e

TMPDIR="$(mktemp -d /tmp/bcast-relay.XXXXXX)"
trap "rm -rf '${TMPDIR}'" EXIT

curl --location --output "${TMPDIR}/bcast-relay.tgz" https://github.com/britannic/ubnt-bcast-relay/raw/master/payload.tgz
tar -xf "${TMPDIR}/bcast-relay.tgz" -C "${TMPDIR}"
sudo bash "${TMPDIR}/setup.sh"
