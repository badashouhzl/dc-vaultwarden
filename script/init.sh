#!/bin/sh

# 工作路径
g_workPath=$(cd `dirname \$0`; pwd -P)
cd $g_workPath

. $g_workPath/script/func.sh


# 创建网络
echo "----- create network ------"
mkNetworkPublic "net-public"
mkNetworkPrivate "net-private"


setEnv "path" "$g_workPath" $g_workPath/.env
setEnv "uid" "`id -u`" $g_workPath/.env
setEnv "gid" "`id -g`" $g_workPath/.env

if [ $# -gt 0 ]
then
	if [ "$1" == "private" ]
	then 
		setEnv "network" "net-private" $g_workPath/.env \
		&& sed -i "s/^        # ipv4_address/        ipv4_address/" docker-compose.yaml \
		&& succEcho "convert private success"
	elif [ "$1" == "public" ]
	then
		setEnv "network" "net-public" $g_workPath/.env \
		&& sed -i "s/^        ipv4_address/        # ipv4_address/" docker-compose.yaml \
		&& succEcho "convert public success"
	fi
fi

