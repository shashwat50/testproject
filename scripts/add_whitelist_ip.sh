#!/usr/bin/env bash

set -e

DIR=$(dirname $0)
source $DIR/common.sh

# Functions

valid_ip_or_cidr() {
  local ip=$1
  local stat=1

  if [[ $ip =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))?$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
      && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

usage() {
  echo "usage: $0 <domain> <ip>" >&2
  exit 1
}

modify_whitelist() {
  local site_id=$1
  local ips=$2

  post /api/prov/v1/sites/configure/whitelists \
    "site_id=$site_id&rule_id=api.acl.blacklisted_ips&ips=$ips"
}

# Main

DOMAIN=$1
NEW_IP=$2

test -z "$DOMAIN" && usage
test -z "$NEW_IP" && usage
valid_ip_or_cidr $NEW_IP || { echo "Invalid IP or CIDR format: $NEW_IP" >&2; usage; }

echo Whitelisting $NEW_IP on $DOMAIN...

SITES=$(list_sites)
test -z "$SITES" && { echo "Failed to retrieve sites" >&2; exit 1; }

R_SITE=$(echo $SITES | extract_site $DOMAIN)
test -z "$R_SITE" && { echo "Site not found: $DOMAIN" >&2; exit 1; }

SITE_ID=$(echo $R_SITE | extract_site_id)
echo Site ID: $SITE_ID

EXCEPTIONS=$(echo $R_SITE | extract_blacklist_exceptions)
if echo $EXCEPTIONS | fgrep "$NEW_IP" > /dev/null; then
  echo "Whitelist entry already exists: $NEW_IP. Skipping."
  exit
fi

RESULT=$(modify_whitelist "$SITE_ID" "$NEW_IP")
test -n "$DEBUG" && echo $RESULT | jq '.'

RESULT_STATUS=$(echo $RESULT | jq '.res')
echo "Result ($RESULT_STATUS): $(echo $RESULT | jq '.res_message')"

test "$RESULT_STATUS" = "0"
