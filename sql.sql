--------------任意地方执行-------------------
--------------------------------------------
-- 创建数据库和用户
CREATE DATABASE vaultwarden;
CREATE USER vaultwarden WITH ENCRYPTED PASSWORD 'vaultwarden';

-- 授予数据库连接权限（可选，通常自动拥有）
GRANT CONNECT ON DATABASE vaultwarden TO vaultwarden;
--------------------------------------------


-------进入到刚创建的 vaultwarden 库中-------
--------------------------------------------
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
--------------------------------------------