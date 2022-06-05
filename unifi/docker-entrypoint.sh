#!/bin/sh

timeout 20 bash -c 'until printf "" 2>/dev/null >/dev/tcp/localhost/22; do sleep 1; done'
ssh -o StrictHostKeyChecking=no -q root@localhost "mkdir -p /mnt/data/on_boot.d && find -L /mnt/data/on_boot.d -mindepth 1 -maxdepth 1 -type f -print0 | sort -z | xargs -0 -r -n 1 -- sh -c 'if test -x \"\$0\"; then echo \"%n: running \$0\"; \"\$0\"; else case \"\$0\" in *.sh) echo \"%n: sourcing \$0\"; . \"\$0\";; *) echo \"%n: ignoring \$0\";; esac; fi'"

set -e

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"
