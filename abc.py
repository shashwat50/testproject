#!/usr/bin/env python
# python cidr.py 192.168.1.1/24

import sys, struct, socket
import ipaddress


if sys.argv[1].find('-') == -1:
	if sys.argv[1].find('/') == -1:
        	sys.argv[1]=sys.argv[1]+"/32"
	(ip, cidr) = sys.argv[1].split('/')
	cidr = int(cidr) 
	host_bits = 32 - cidr
	i = struct.unpack('>I', socket.inet_aton(ip))[0] # note the endianness
	start = (i >> host_bits) << host_bits # clear the host bits
	end = start | ((1 << host_bits) - 1)
	for i in range(start, end+1):
    		print(socket.inet_ntoa(struct.pack('>I',i)))

else:

	start,end = sys.argv[1].split("-")
	start_ip = ipaddress.IPv4Address(start)	
	end_ip = ipaddress.IPv4Address(end)
	for ip_int in range(int(start_ip), int(end_ip)):
		print(ipaddress.IPv4Address(ip_int))
