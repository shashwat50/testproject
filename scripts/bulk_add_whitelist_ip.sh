#!/usr/bin/env bash

DIR=$(dirname $0)

usage() {
  echo "usage: $0 <ip> <domain> [domain...]" >&2
  exit 1
}

NEW_IP=$1
test -z "$NEW_IP" && usage
shift

DOMAINS="$*"
test -z "$DOMAINS" && usage

for d in $DOMAINS; do
  $DIR/add_whitelist_ip.sh $d $NEW_IP
done
