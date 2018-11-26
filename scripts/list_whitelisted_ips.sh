#!/usr/bin/env bash

set -e

DIR=$(dirname $0)
source $DIR/common.sh

usage() {
  echo "usage: $0 <domain> [domain...]" >&2
  exit 1
}

DOMAINS=$*
test -z "$DOMAINS" && usage

SITES=$(list_sites)

RESULT=""

for d in $DOMAINS; do
  RESULT="$RESULT $(echo $SITES | extract_site $d | extract_blacklist_exceptions)"
done

echo $RESULT | tr ' ' '\n' | sort -u
