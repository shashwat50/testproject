#!/usr/bin/env python
import ipaddress
net = ipaddress.ip_network('123.45.67.64/27')
for a in net:
	print(a)
