#!/usr/bin/env bash

set -e

BATCH_SIZE=25
BATCH_SEQ=$(seq 0 $(($BATCH_SIZE - 1)))
DIR=$(dirname $0)

usage() {
  echo "usage: $0 <csv-file>" >&2
  exit 1
}

cleanup() {
  for j in $BATCH_SEQ; do
    rm -f ${COLLECTORS[$j]}
  done
}
trap cleanup EXIT

IN_FILE=$1
test -z "$IN_FILE" && usage

declare -a COLLECTORS

for j in $BATCH_SEQ; do
  COLLECTORS[$j]=$(mktemp /tmp/bulk_whois_XXXXXX.txt)
done

i=0
for row in $(cat $IN_FILE); do
  ip=$(echo $row | \
    awk -F, '{print $1}' | \
    tr -d '"')
  partner=$(echo $row | \
    awk -F, '{print $2}' | \
    tr -d '"')

  $DIR/whois_to_csv.sh -i $ip $partner > ${COLLECTORS[$i]} &  

  i=$(($i + 1))
  if (( $i >= $BATCH_SIZE )); then
    i=0
    wait

    for j in $BATCH_SEQ; do
      cat ${COLLECTORS[$j]}
      echo -n "" > ${COLLECTORS[$j]}
    done
  fi
done
