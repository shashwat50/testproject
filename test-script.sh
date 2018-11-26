export API_ID=26569
export API_KEY=948165e3-3313-4c45-b3ed-9541b3e2c285
export PATH="/usr/local/rvm/rubies/ruby-2.3.1/bin:$PATH"

echo ========================================================

SITES=$(cat ./data/test_sites.txt)

export IP=$1

#OPTS=""
#if [ "$LIST" = "resolved" ]; then
#  OPTS="-r"
#elif [ "$LIST" = "redundancies" ]; then
#  OPTS="-p" # print
#fi

bin/wctl list -s $SITES > ./data/all_ips_list.txt

for i in `cat ./data/all_ips_list.txt`
do
a=`sh ./scripts/ip_check.sh $IP $i`
if [ $a == "yes" ]
then
echo "IP Already Whitelisted"
echo ========================================================
exit
fi
done
echo "IP is not Whitelisted"
echo ========================================================
