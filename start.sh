echo "Getting List of Whitelisted IP Addresses......"

> cidr.txt
for i in `cat data/test_sites.txt`
do
echo "Getting whitelisted IP's for $i"
scripts/list_whitelisted_ips.sh $i >> cidr.txt
done

cat cidr.txt | sort -n | uniq | grep -v '-'  > new_cidr.txt
echo ""
echo ""
> Final_IP.txt

echo "Checking if IP's already present........."

python2 comp.py 

SITES=$(cat ./data/test_sites.txt | tr '\n' ',')

if [ `cat Final_IP.txt | wc -l` -eq 0 ]
then
echo "No IP to be added."
else
bin/wctl addset -s $SITES < Final_IP.txt
echo "IP's added successfully!"
fi
