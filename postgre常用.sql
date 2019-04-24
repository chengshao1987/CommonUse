----- 以下是postgre数据库安装步骤-----------------
1,下载源码并编译安装
#cd /opt/src
# wget https://ftp.postgresql.org/pub/source/v9.4.8/postgresql-9.4.8.tar.bz2
#tar xjvf   postgresql-9.4.8.tar.bz2
#cd postgresql-9.4.8
#./configure --prefix=/opt/app/postgresql-9.4.8
make && make install

2，设置环境变量：
#vim /etc/profile

export PATH=/opt/app/postgresql-9.4.8/bin:$PATH
export PGDATA=/opt/data
export PGHOME=/opt/app/postgresql-9.4.8
#export LANG=zh_CN.UTF-8
export PGPORT=5432

#source /etc/profile

3，创建目录及用户
   adduser postgre
   mkdir -p /opt/data;chown -R postgre.postgre /opt/data

4，初始化数据库
  # su - postgre
  #initdb -D /opt/data #--locale=C 
5,启动
  # pg_ctl start -l log.file |status

***服务方式启动
 cp /opt/src/postgresql-9.4.8/contrib/start-scripts/linux /etc/init.d/rc.postgresql 修改相应变量
 /etc/init.d/rc.postgresql start

6，本地登录
   #su - postgre
   $psql postgres
7,修改超级用户密码
  $psql postgres
   postgres=# \password 
8，修改登录权限配置文件
   $vim /opt/data/pg_hba.conf

     # TYPE  DATABASE        USER            ADDRESS                 METHOD

     # "local" is for Unix domain socket connections only
        local   all             all                                     trust
     # IPv4 local connections:
        host    all             all             127.0.0.1/32            md5
        host    all             all             172.16.2.0/24     md5 #172.16.2.%
        host    all             all         192.168.0.0/16        md5 # 192.168.%
   $vim postgresql.conf
    listen_addresses = '*'          # what IP address(es) to listen on;
    #listen_addresses = 'localhost' # what IP address(es) to listen on;

9,使配置生效
  $pg_ctl reload
 
10，远程登录
  $psql postgres -h 172.16.2.142 -p5432
11，创建用户
  postgres=# create user dejiu with password '12345678';
  CREATE ROLE
  postgres=# create database wangdejiu owner dejiu;
12，新用户登录
   $ psql -h172.16.2.142 -Udejiu wangdejiu
   
----- 以上是postgre数据库安装步骤-----------------


Postgre8.3配置参数需要修改Postgresql.conf,参数包含以下大类：
连接和认证：监听地址，端口，认证最长时间等等
资源消耗：内存，空闲空间，内核资源使用，后端写进程，基于开销的清理延迟
预写式日志：事物提交的时候，postgre必须等待操作系统将日志写到磁盘上；checkpoint和归档
查询规划：查询规划器涉及到的一些参数配置,hash,索引，位图，nestloop,mergejoin
错误报告和日志：什么时候记录日志，记录什么
运行时统计：设置服务器统计信息收集特性
自动清理：autovacuum涉及到的一些参数
客户端连接缺省：默认的表空间，时区等等一些参数
锁管理：死锁超时时长以及每个事物能包含的锁数量
版本和平台兼容性： 对PostgreSQL 版本的兼容性
预置选项：只读参数
自定义的选项：在 postgresql.conf 里设置自定义变量
开发人员选项：修改postgre的源代码，在某些情况下可以帮助恢复严重损坏了的数据库
短选项：服务器参数配置的一些快捷短语



--postgre数据库本地登录
./bin/psql -h 127.0.0.1 -d postgres -U postgres -p 5432

--postgre重新加载配置文件
pg_ctl reload -D /opt/websuite/postgre/postgresql_data/

pg_ctl -D /opt/websuite/postgre/postgresql_data/ -l logfile start

--修改用户密码
alter user postgres with PASSWORD 'postgre@ttpai';

--查看某个用户的权限
select * from information_schema.table_privileges where grantee='tableau';


客户端运行show all 显示所有参数 使用set 参数名=参数值这种方式配置参数

pg_hba.conf是客户端认证配置文件，定义如何认证客户端。
pg_ident.conf用来配置哪些操作系统用户可以映射为数据库用户。
postgresql.conf 是主服务器配置文件
