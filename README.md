# dc-vaultwarden

#### 介绍
密码管理器

## 相关网址
- [github](https://github.com/dani-garcia/vaultwarden)
- [客户端下载](https://bitwarden.com/download/)
- [git wiki](https://github.com/dani-garcia/vaultwarden/wiki/Proxy-examples)
- [git wiki 中文翻译](https://rs.ppgg.in/)

## 相关依赖
此容器依赖 postgresSQL 数据库

## 使用过的版本
- vaultwarden/server:1.34.1

## 部署
### postgres 脚本
1. 创建库和用户
	```sql
	-- 创建数据库和用户
	CREATE DATABASE vaultwarden;
	CREATE USER vaultwarden WITH ENCRYPTED PASSWORD 'vaultwarden';

	-- 授予数据库连接权限（可选，通常自动拥有）
	GRANT CONNECT ON DATABASE vaultwarden TO vaultwarden;
	```
1. 权限设置(进入到 vaultwarden)
	```sql
	-- 授予 schema 权限
	GRANT USAGE ON SCHEMA public TO vaultwarden;
	GRANT CREATE ON SCHEMA public TO vaultwarden;

	-- 授予现有对象权限
	GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO vaultwarden;
	GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO vaultwarden;
	GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO vaultwarden;

	-- 设置默认权限
	ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO vaultwarden;
	ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO vaultwarden;
	ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO vaultwarden;
	```

### 配置 .env
- .env: 容器的配置文件，可以修改，里面有以下重要参数
	- image: docker 镜像
	- DOMAIN: 反射代理时的请求链接
	- SIGNUPS_ALLOWED: 是否可以注册账号
	- DATABASE_URL: 数据存放点
	- 其它及详情参数文件中有注释
- docker-compose.yaml: docker 容器编排文件无需修改
- ctrl: 本容器的一些命令封装

### 部署容器
时空目录后运行下面命令
```bash
chmod +x ctrl
ctrl init # 或 ctrl init private #(容器无网络，需要代理)
docker compose up -d
```


### 容器编排 文件说明
```
dc-vaultwarden
├─ .env                    docker-compose.yaml 的配置文件
├─ ctrl                    本容器的一些命令封装
├─ docker-compose.yaml     容器编排文件
├─ README.en.md
├─ README.md
├─ script                  一些脚本提供给 ctrl 调用
├─ sql.sql                 容器需要的 pgsql 脚本
└─ vaultwarden.nginx.conf  nginx 代理配置文件，要使用 nginx 代理的, 需要的使用
