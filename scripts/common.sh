#!/usr/bin/env bash

test -z "$API_KEY" && { echo "Must set API_KEY" >&2; exit 1; }
test -z "$API_ID" && { echo "Must set API_ID" >&2; exit 1; }

HOST=https://my.incapsula.com
KEY_PARAMS="api_key=$API_KEY&api_id=$API_ID"

post() {
  local path=$1
  local params=$2

  curl -s -X POST "$HOST$path?$KEY_PARAMS&$params"
}

list_sites() {
  post /api/prov/v1/sites/list ""
}

# input: site listing
extract_site() {
  local domain=$1
  jq -r ".sites[] | select(.domain==\"$domain\") | ."
}

# input: site object
extract_site_id() {
  jq -r ".site_id"
}

# input: site object
extract_blacklist_exceptions() {
  jq -r '.security.acls.rules[] |
    select(.id=="api.acl.blacklisted_ips") |
    .exceptions[].values[] |
    select(.id=="api.rule_exception_type.client_ip") |
    .ips[]'
}

