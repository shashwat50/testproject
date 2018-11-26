# Incapsula Whitelist Control

## Requirements

* Ruby >= 2

## Usage

The `wctl` command executes one of a number of sub-commands.
Run `wctl -h` for more info.

All sub-commands accept a list of sites to which the operation will apply, separated by a comma:
```
-s <site>,[site],[site...]
```

By adding `-v` to any command, you can see verbose output
including requests and responses.

### Access Control

Before using `wctl` you must export `API_KEY` and `API_ID` environment variables.

### Deleting All Whitelists

CAUTION: This actually does what it says.

To delete all whitelist entries for a site, run:
```bash
wctl deleteall -s the.site.com
```

Deletions occur sequentially, so it may take a while dpending on how many rules need deleting.

### Listing Effective Whitelist Information

The easiest way to list effective whitelist information
is to run this job:
https://test-access.appdirect.com/job/list-all-whitelisted-ips/

But, if you need to run from the command line, here's how.

List the entire effective whitelist as stored in Incapsula, for the given sites:
```bash
wctl list -s the.site.com
```

List the effective whitelist that has has redundancies removed
(i.e. IP addresses that match an existing CIDR):
```bash
wctl list -r -s the.site.com
```

Print redundantly applied IP addresses that match existing CIDRs:
```bash
wctl list -p -s the.site.com
```

### Adding Whitelist Entries

Pass a new-line separated list of IP addresses, or CIDRs as standard input
to `wctl` to apply them to the specified sites. Duplicates
and redundantly specified IP addresses are skipped.

```bash
wctl addset -s the.site.com < my_whitelist.txt
```
