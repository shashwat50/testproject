#! /bin/bash

MAXCDN_ARRAY=$2

if [ `echo $MAXCDN_ARRAY | grep -v '/' | wc -l` -eq 1 ] 
then MAXCDN_ARRAY=$MAXCDN_ARRAY/32;
fi

IP=$1

function in_subnet {
    # Determine whether IP address is in the specified subnet.
    #
    # Args:
    #   sub: Subnet, in CIDR notation.
    #   ip: IP address to check.
    #
    # Returns:
    #   1|0
    local ip ip_a mask netmask sub sub_ip rval start end

    # Define bitmask.
    local readonly BITMASK=0xFFFFFFFF

    [[ "${DEBUG}" == "" ]] && DEBUG=0

    # Read arguments.
    IFS=/ read sub mask <<< "${1}"
    IFS=. read -a sub_ip <<< "${sub}"
    IFS=. read -a ip_a <<< "${2}"
    #IFS=. read -a ip_a <<< "${range}"
    # Calculate netmask.
    netmask=$(($BITMASK<<$((32-$mask)) & $BITMASK))

    # Determine address range.
    start=0
    for o in "${sub_ip[@]}"
    do
        start=$(($start<<8 | $o))
    done
    start=$(($start & $netmask))
    end=$(($start | ~$netmask & $BITMASK))

    
# Convert IP address to 32-bit number.
    ip=0
    for o in "${ip_a[@]}"
    do
        ip=$(($ip<<8 | $o))
    done

    # Determine if IP in range.
    (( $ip >= $start )) && (( $ip <= $end )) && rval=1 || rval=0

    (( $DEBUG )) &&
        printf "ip=0x%08X; start=0x%08X; end=0x%08X; in_subnet=%u\n" $ip $start $end $rval 1>&2

    echo "${rval}"
}

if [ `in_subnet $MAXCDN_ARRAY $IP` -eq 1 ]
then
echo yes
else
echo no
fi
