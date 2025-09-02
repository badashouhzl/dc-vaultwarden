#!/bin/bash

succEcho() {
	str="$1"
	echo -e "\033[32m$str\033[0m"
}

errEcho() {
	str="$1"
	echo -e "\033[31m$str\033[0m"
}

warnEcho() {
	str="$1"
	echo -e "\033[33m$str\033[0m"
}

execCmd() {
	local cmd="$1"
	local succ="$2"
	local err="$3"

	eval "$cmd" \
		&& {
			succEcho "$succ"
		} \
		|| {
			errEcho "$err. cmd=: '$cmd'"
			exit 1
		}
}

# 创建 network(可以访问外网)
# @param $1 network 名称
mkNetworkPublic() {
	netName="$1"
	b=`docker network ls | grep ${netName} | awk '{print $2}'`

	if [ ${#netName} == ${#b} ]
	then
		succEcho "network ${netName} exist"
	else
		execCmd "docker network create --driver bridge --subnet=172.18.0.0/16 ${netName}" \
			"create network ${netName}" \
			"create network ${netName} fail"
	fi
}

# 创建 network(内网)
# @param $1 network 名称
mkNetworkPrivate(){
	netName="$1"
	b=`docker network ls | grep ${netName} | awk '{print $2}'`

	if [ ${#netName} == ${#b} ]
	then
		succEcho "network ${netName} exist"
	else
		execCmd "network create --driver bridge --subnet=172.19.0.0/16 --internal ${netName}" \
			"create network ${netName}" \
			"create network ${netName} fail"
	fi
}

# 创建 volume
# @param $1 volume 名称
mkVolume(){
	volName="$1"
	b=`docker volume ls | grep ${volName} | awk '{print $2}'`

	if [ ${#volName} == ${#b} ]
	then
		succEcho "volume ${volName} exist"
	else
		execCmd "docker volume create  ${volName}"\
			"create volume ${volName}" \
			"create volume ${volName} fail"
	fi
}

# 校验文件是否存在
# @param $1 文件名称
# @return 存在返回 1, 不存在返回 0
checkFileExist(){
	filePaeh="$1"
	if [ -f "$filePaeh" ];then
		succEcho "$filePaeh exist"
		return 1
	fi

	errEcho "$filePaeh not exist"
	
	return 0
}


# 设置 环境变量文件中的 键(key)和值(value)
# @param $1 环境变量的 键(key)
# @param $2 环境变量的 值(value)
# @param $3 环境变量文件 默认值为 .env
setEnv() {
	local key="$1"
	local value="$2"
	local file="${3:-.env}"

	if [[ -z "$key" ]]; then
		errEcho "错误：必须提供一个环境变量名作为参数。"
		return 1
	fi

	if [[ ! -f "$file" ]]; then
		errEcho "错误：文件 $file 不存在。"
		return 1
	fi

	# 判断变量是否存在
	if grep -q "^$key=" "$file" 2>/dev/null; then
		# 存在，则替换整行
		sed -i "s|^$key=.*|$key=$value|" "$file"
	else
		# 不存在，则追加
		errEcho "$key=$value" >> "$file"
	fi

	return 0
}

# 设置 环境变量文件中的 键(key)和值(value)，有注释会解除注释并设置新值
# @param $1 环境变量的 键(key)
# @param $2 环境变量的 值(value)
# @param $3 环境变量文件 默认值为 .env
setEnv1() {
	local key="$1"
	local value="$2"
	local file="${3:-.env}"

	if [[ -z "$key" ]]; then
		errEcho "错误：必须提供一个环境变量名作为参数。"
		return 1
	fi

	if [[ ! -f "$file" ]]; then
		errEcho "错误：文件 $file 不存在。"
		return 1
	fi

	# 判断变量是否存在（无论是否被注释）
	if grep -Eq "^[#]*\s*${key}=" "$file"; then
		# 使用 sed 取消注释并设置新值
		sed -i "s|^[#]*\s*${key}=.*|${key}=${value}|" "$file"
	else
		# 追加新变量
		errEcho "${key}=${value}" >> "$file"
	fi

	return 0
}


# 删除 环境变量文件中的 键(key)
# @param $1 环境变量的 键(key)
# @param $3 环境变量文件 默认值为 .env
delEnv() {
	local key="$1"
	local file="${2:-.env}"

	if [[ -z "$key" ]]; then
		errEcho "错误：必须提供一个环境变量名作为参数。"
		return 1
	fi

	if [[ ! -f "$file" ]]; then
		errEcho "错误：文件 $file 不存在。"
		return 1
	fi

	sed -i "/^$key=/d" "$file"

	return 0
}

# 获取 环境变量文件中的 键(key)对应的值(value)
# @param $1 环境变量的 键(key)
# @param $3 环境变量文件 默认值为 .env
getEnv() {
	local key="$1"
	local file="${2:-.env}"

	if [[ -z "$key" ]]; then
		errEcho "错误：必须提供一个环境变量名作为参数。"
		return 1
	fi

	if [[ ! -f "$file" ]]; then
		errEcho "错误：文件 $file 不存在。"
		return 1
	fi

	# 使用 grep 匹配以 key= 开头的行，并用 cut 提取等号后的值
	local value=$(grep "^$key=" "$file" | cut -d '=' -f2-)

	# 判断是否找到
	if [[ -n "$value" ]]; then
		errEcho "$file: $key=$value"
	else
		# 可选：输出调试信息
		# echo -e "警告：未在 $file 中找到 $key。"
		errEcho "$file: $key=$value"
	fi

	return 0
}


