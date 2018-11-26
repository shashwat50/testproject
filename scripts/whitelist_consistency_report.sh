#!/usr/bin/env bash

DIR=$(dirname $0)
source $DIR/common.sh

usage() {
  echo "usage: $0 <domain> [domain...]" >&2
  exit 1
}

DOMAINS=$*
test -z "$DOMAINS" && usage

ALL_IPS=$($DIR/list_whitelisted_ips.sh $DOMAINS | sed '/^$/d')

SITES=$(list_sites)

RESULT=0

for d in $DOMAINS; do
  site_exceptions=$(echo $SITES | extract_site $d | extract_blacklist_exceptions | tr ' ' '\n' | sed '/^$/d' | sort -u)

  missing=$(comm -3 <(echo "$ALL_IPS") <(echo "$site_exceptions"))

  if [ -n "$missing" ]; then
    echo ===============================================================
    echo "IPs missing for $d ($(echo "$missing" | wc -l))..."
    echo "$missing"

    RESULT=1
  fi
done

if [ $RESULT -eq 0 ]; then
  echo "[✓] All sites are consistent"
else
  echo ===============================================================
  echo "[✗] Some sites are inconsistent and need correcting"
  exit 1
fi
