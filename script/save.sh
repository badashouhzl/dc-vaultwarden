#!/bin/sh


# 工作路径
g_workPath=$(cd `dirname \$0`; pwd -P)
cd $g_workPath

. $g_workPath/script/func.sh

g_volumeName="$1"

if [ -z "$2" ]
then
	packName=$g_volumeName.tar.gz
else
	packName="$2"
fi

mkdir -p backup

cmd="cd /backVolume && tar czf /backup/$packName ."

docker run --rm \
	-v $g_volumeName:/backVolume:rw \
	-v $g_workPath/backup:/backup:rw \
	ubuntu sh -c \
	"$cmd" \
	&& succEcho "volume $g_volumeName backup $g_workPath/backup/$packName success"
