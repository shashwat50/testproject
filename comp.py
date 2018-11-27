#!/usr/bin/env python

from netaddr import *

ipset=IPSet()
cidrset=IPSet()
finalipset=IPSet()

f = open("new_cidr.txt","r")
for line in f:
	line=line.rstrip('\n')
	cidrset.add(line)

p = open("ip.txt","r")
for line in p:
	line=line.rstrip('\n')
	ipset.add(line)

o = open("Final_IP.txt","a")

q = open("IP_CIDR.txt","a")

print "IP's to be whitelisted...."
for i in ipset:
	if (i in cidrset) == False:
		print i
		o.write(str(i))
		o.write("\n")

	if (i in cidrset) == True:
		print str(i) + " is already whitelisted.Skipping...."

o.close()

o = open("Final_IP.txt","r")

for line in o:
        line=line.rstrip('\n')
        finalipset.add(line)
			
q.write(str(finalipset))

q.close()
o.close()
p.close()
f.close()
