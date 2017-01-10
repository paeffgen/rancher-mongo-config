#!/bin/bash
sleep 5
DIG=/usr/bin/dig
CURL=/usr/bin/curl

STACK=`$CURL -s http://rancher-metadata/latest/self/stack/name`
SERVICE=`$CURL -s http://rancher-metadata/latest/self/service/name`
NAME=$STACK-$SERVICE
SELF=`$CURL -s http://rancher-metadata/latest/self/container/name`

function scaleup {
	#MYIP=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
	#$DIG A $MONGO_SERVICE_NAME +short > ips.tmp
	$CURL -s http://rancher-metadata/latest/self/service/containers | grep -Eo "$NAME-[0-9]+" > ips.tmp
	for IP in $(cat ips.tmp); do
		IS_MASTER=$(mongo --host $IP --eval "printjson(db.isMaster())" | grep 'ismaster')
		if echo $IS_MASTER | grep "true"; then
			mongo --host $IP --eval "printjson(rs.add('$SELF:27017'))"
			return 0
		fi
	done
	return 1
}

# Script starts here
#if [ $($DIG A $MONGO_SERVICE_NAME +short | wc -l) -gt 3 ]; then
	scaleup
#fi
