#!/usr/bin/env bash

RETRIES=3

usage() {
  echo "usage: $0 [-i] <ip> <partner>" >&2
  echo "  -i   include IP as first column"
  exit 1
}

if [ "$1" == "-i" ]; then
  INC_IP=yes
  shift
fi

IP=$1
test -z "$IP" && usage

PARTNER=$2
test -z "$PARTNER" && usage

OUT_FILE=$(mktemp /tmp/whois_output_XXXXXX.txt)

cleanup() {
  rm -f $OUT_FILE
}

trap cleanup EXIT

for i in $(seq 1 $RETRIES); do
  whois $IP > $OUT_FILE
  if [ $? -eq 0 ]; then
    break
  fi
  sleep 1
done

if [ $? -ne 0 ]; then
  echo "$IP,<error>"
  exit 1
fi

REFER=$(cat $OUT_FILE | \
    grep -m 1 "Ref:" | \
    awk -F: '{print $3}' | \
    awk -F'/' '{print $3}' | \
    sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

FIELDS="descr country inetnum inetnum"

if [[ $REFER = "whois.arin.net" ]]; then
  FIELDS="OrgName Country NetRange CIDR"
fi

#echo $FIELDS

RESULT="$IP,$PARTNER"

for f in $FIELDS; do

  VALUE=$(cat $OUT_FILE | \
    grep -m 2 "$f:" | \
    awk -F: '{print $2}' | \
    awk -F'#' '{print $1}' | \
    sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  RESULT=$RESULT,\"$VALUE\"
done

# Trim leading comma
RESULT=$(echo $RESULT | sed 's/^,//')

echo $RESULT
