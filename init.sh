#!/bin/bash

# 工作路径
g_workPath=$(cd `dirname \$0`; pwd -P)
cd $g_workPath 


# 创建 network(可以访问外网)
# @param $1 network 名称
mkNetworkPublic() {
	netName="$1"
	b=`docker network ls | grep ${netName} | awk '{print $2}'`

	if [ ${#netName} == ${#b} ]
	then
		echo "network ${netName} exist"
	else
		echo "network ${netName} not exist"
		docker network create --driver bridge --subnet=172.18.0.0/16 ${netName}
		echo "create network ${netName}"
	fi
}

# 创建 network(内网)
# @param $1 network 名称
mkNetworkPrivate(){
	netName="$1"
	b=`docker network ls | grep ${netName} | awk '{print $2}'`

	if [ ${#netName} == ${#b} ]
	then
		echo "network ${netName} exist"
	else
		echo "network ${netName} not exist"
		docker network create --driver bridge --subnet=172.19.0.0/16 --internal ${netName}
		echo "create network ${netName}"
	fi
}

# 创建 volume
# @param $1 volume 名称
mkVolume(){
	volName="$1"
	b=`docker volume ls | grep ${volName} | awk '{print $2}'`

	if [ ${#volName} == ${#b} ]
	then
		echo "volume ${volName} exist"
	else
		echo "volume ${volName} not exist"
		docker volume create  ${volName}
		echo "create volume ${volName}"
	fi
}

# 校验文件是否存在
# @param $1 文件名称
# @return 存在返回 1, 不存在返回 0
checkFileExist(){
	filePaeh="$1"
	if [ -f "$filePaeh" ];then
		echo "$filePaeh exist"
		return 1
	fi

	echo "$filePaeh not exist"
	return 0
}

# 修改 .env 文件
# @param $1 文件所在路径
changeEnvFile(){
	basepath="$1"

	reg=s/\$\{path\}/${basepath//\//\\\/}/g
	sed -i $reg .env

	uid=`id -u`
	reg=s/\$\{uid\}/${uid/\//\\\/}/g
	sed -i $reg .env

	gid=`id -g`
	reg=s/\$\{gid\}/${gid/\//\\\/}/g
	sed -i $reg .env
}



# 创建网络
echo "----- create network ------"
mkNetworkPublic "net-public"
mkNetworkPrivate "net-private"

# 创建卷
echo "----- create volume ------"
mkVolume "vol-vaultwarden"


changeEnvFile $g_workPath