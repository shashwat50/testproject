> cidr.txt
for i in `cat data/test_sites.txt`
do
echo ""
echo "-------------------------------------------------------------------------------"
echo ""
echo "Getting whitelisted IP's for $i......."
scripts/list_whitelisted_ips.sh $i > cidr.txt

cat cidr.txt | sort -n | uniq | grep -v '-'  > new_cidr.txt
echo ""
> Final_IP.txt
> IP_CIDR.txt
> Final_IP_CIDR.txt

echo "Checking if IP's already present in $i."

python2 comp.py 

SITES=$i

if [ `cat IP_CIDR.txt | wc -w` -gt 0 ]
then
cat IP_CIDR.txt | cut -d '[' -f2 | cut -d ']' -f1 | tr ',' '\n' | cut -d "'" -f2 > Final_IP_CIDR.txt
fi

if [ `cat Final_IP_CIDR.txt | wc -w` -eq 0 ]
then
echo ""
echo "No IP's to be added in $i."
else
bin/wctl addset -s $SITES < Final_IP_CIDR.txt
echo ""
echo "IP's added successfully in $i!"
fi
done
