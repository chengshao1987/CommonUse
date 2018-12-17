--再谈谈Greenplum
1. 支持列存，行存，混合存储。
2. 支持扩展的外部数据源（如阿里云提供的极为廉价的OSS外部存储）。
3. 支持并行的数据导入导出。
4. 支持非常完备的OLAP语法。
5. 支持MADLib分析函数库。
6. 支持R，Python, Java的数据库UDF编程。
7. 支持主备，数据节点mirror，在线扩展数据节点。
8. 支持用户资源（并发，CPU,MEMORY）调度。
9. 支持丰富的数据类型（数字、字符串、比特串、货币、字节流、时间、布尔、几何、网络地址、数组、GIS、XML、JSON、复合、枚举）。
10. 支持R隐式并行。11. 扩展方面支持用户自定义数据类型、操作符、索引、UDF、窗口、聚合。
12. 支持全文检索、字符串模糊查询（fuzzystrmatch） 
13. 支持ORACLE兼容包插件orafunc14. 多种索引支持(btree)，支持函数索引，支持partial index
15. 内置丰富的函数、操作符、聚合、窗口查询




--gp存储容量
存储空间除了用来存储用户数据，还需要：landing backup files and data load files
空系统的存储空间：disk_size * number_of_disks
除去系统开销：(raw_capacity * 0.9) / 2 = formatted_disk_space
为了获取最佳性能，容量不超过70%：formatted_disk_space * 0.7 = usable_disk_space
如果开启了segments镜像，数据量翻倍，并且还需要其他空间作为查询的工作区域（大的查询会生成临时文件）：
With mirrors: (2 * U) + U/3 = usable_disk_space
Without mirrors: U + U/3 = usable_disk_space
临时空间和用户空间是可以通过表空间指定到不同的位置的。
除了数据以外的消耗：Page、Row、Attribute、Index（索引也被认为是用户数据）
其它空间消耗：1.系统日志消耗20MB，WAL日志消耗2 * checkpoint_segments + 1，默认参数为8，大小为64MB；
			  2.GPDB的Log Files;
              3.性能监控用到的agent会一直搜集数据信息，并且不会自动清空






--增加主键约束
alter table  ttpai_boss_v1."BOSS_ACCOUNT" add constraint BOSS_ACCOUNT_pk primary key (ID);

--修改表名
alter table  ttpai_boss_v1."BOSS_ACCOUNT" rename to BOSS_ACCOUNT;


--gp字段命名
 不能以数字开头
 
 --创建schema
  create schema ttpai_boss_demension;
  
 --删除schema
 drop schema if exists ttpai_test cascade;

 --修改schema名字
   alter schema boss_demension rename  to ttpai_boss_demension;

 --gp给schema赋权
 grant all on schema ttpai_boss_demension to tableau;
 revoke all on schema ttpai_boss_demension from tableau;
 
 --返回星期几
 select EXTRACT(dow FROM now())

 
 --gp杀某个连接 datname是数据库名
 SELECT procpid, pg_terminate_backend(procpid) 
FROM pg_stat_activity 
WHERE datname = 'boss_demension' AND procpid <> pg_backend_pid();

--删除数据库
drop database boss_demension;



--gp查看各个节点的剩余空间  
SELECT t.*,t.dfspace/1024/1024 "剩余空间GB"
FROM gp_toolkit.gp_disk_free t 
ORDER BY dfsegment;

--gp查看某个数据库占用空间
select pg_size_pretty(pg_database_size('ttpai_boss_v1'));


--gp修改用户密码
 alter user tableau with password 'readuser';

 --月初第一天
 select date_trunc('month', timestamp '2001-02-16 20:38:40')	
 
 --查看服务器和客户端编码(服务器和客户端编码要一致,不然有的客户端连服务器会报ERRORDATA_STACK_SIZE exceeded  错误
show server_encoding
show client_encoding

--设置客户端编码
set client_encoding ='UTF8';


--pg_class GP数据字典中最重要的一个系统表，保存着所有的表、试图、索引的元数据信息，每个DDL/DML操作都必须跟这个表发送联系。
pg_class

--pg_class.relstorage表示这个对象是什么存储：
 select distinct relstorage from pg_class ;    
 relstorage     
------------    
 a  -- 行存储AO表    
 h  -- heap堆表、索引    
 x  -- 外部表(external table)    
 v  -- 视图    
 c  -- 列存储AO表   
 
 --查询当前数据库有哪些AO表：
select t2.nspname, t1.relname from pg_class t1, pg_namespace t2 where t1.relnamespace=t2.oid and relstorage in ('c', 'a');   

--查找gp的分布键
select attname from pg_attribute 
where attrelid='ttpai_boss_demension."OA_LOWPRICE_CARRER"'::regclass 
and attnum in (SELECT unnest(attrnums) FROM pg_catalog.gp_distribution_policy t where localoid='ttpai_boss_demension."OA_LOWPRICE_CARRER"'::regclass);

--age函数 减去参数，生成一个使用年、月的"符号化"的结果
age('2001-04-10', timestamp '1957-06-13')  --43 years 9 mons 27 days


--计算时间差天数
select extract(day FROM (age('2017-12-10'::date , '2017-12-01'::date)));

--计算时间差秒数
select extract(epoch FROM (now() - (now()-interval '1 day') ));

--清理当前数据库下的所有表：
vacuum

--只清理一张特定的表：
VACUUM mytable;

--清理当前数据库下的所有表同时为查询优化器收集统计信息：
VACUUM ANALYZE;



--表占用空间 schema ttpai_boss_v1
SELECT relname as name, sotdsize/1024/1024 as size_MB, sotdtoastsize as toast, sotdadditionalsize as other
FROM gp_toolkit.gp_size_of_table_disk as sotd, pg_class
WHERE sotd.sotdoid = pg_class.oid and sotd.sotdschemaname like 'ttpai_boss_v1'
ORDER BY relname;
 
--索引占用空间
SELECT soisize/1024/1024 as size_MB, relname as indexname
FROM pg_class, gp_toolkit.gp_size_of_index
WHERE pg_class.oid = gp_size_of_index.soioid
AND pg_class.relkind='i';

--查看主备节点是否正常运行,表中如果status字段有为d的,说明节点挂了，如果有节点挂了使用在master目录使用  gprecoverseg  命令恢复
select * from gp_segment_configuration order by dbid

--查看服务器参数设置(在客户端)
show all 

--linux查看参数设置
gpconfig -s shared_buffers
gpconfig -s max_connections

--linux修改参数设置(重启服务器才生效)
gpconfig -r shared_buffers -v 1024MB 



--gpstate
命令     参数   作用 
gpstate -b =》 显示简要状态
gpstate -c =》 显示主镜像映射
gpstart -d =》 指定数据目录（默认值：$MASTER_DATA_DIRECTORY）
gpstate -e =》 显示具有镜像状态问题的片段
gpstate -f =》 显示备用主机详细信息
gpstate -i =》 显示GRIPLUM数据库版本
gpstate -m =》 显示镜像实例同步状态
gpstate -p =》 显示使用端口
gpstate -Q =》 快速检查主机状态
gpstate -s =》 显示集群详细信息
gpstate -v =》 显示详细信息

--gpconfig
   命令    参数                              作用
gpconfig -c =》 --change param_name  通过在postgresql.conf 文件的底部添加新的设置来改变配置参数的设置。
gpconfig -v =》 --value value 用于由-c选项指定的配置参数的值。默认情况下，此值将应用于所有Segment及其镜像、Master和后备Master。
gpconfig -m =》 --mastervalue master_value 用于由-c 选项指定的配置参数的Master值。如果指定，则该值仅适用于Master和后备Master。该选项只能与-v一起使用。
gpconfig -masteronly =》当被指定时，gpconfig 将仅编辑Master的postgresql.conf文件。
gpconfig -r =》 --remove param_name 通过注释掉postgresql.conf文件中的项删除配置参数。
gpconfig -l =》 --list 列出所有被gpconfig工具支持的配置参数。
gpconfig -s =》 --show param_name 显示在Greenplum数据库系统中所有实例（Master和Segment）上使用的配置参数的值。如果实例中参数值存在差异，则工具将显示错误消息。使用-s=》选项运行gpconfig将直接从数据库中读取参数值，而不是从postgresql.conf文件中读取。如果用户使用gpconfig 在所有Segment中设置配置参数，然后运行gpconfig -s来验证更改，用户仍可能会看到以前的（旧）值。用户必须重新加载配置文件（gpstop -u）或重新启动系统（gpstop -r）以使更改生效。
gpconfig --file =》 对于配置参数，显示在Greenplum数据库系统中的所有Segment（Master和Segment）上的postgresql.conf文件中的值。如果实例中的参数值存在差异，则工具会显示一个消息。必须与-s选项一起指定。
gpconfig --file-compare 对于配置参数，将当前Greenplum数据库值与主机（Master和Segment）上postgresql.conf文件中的值进行比较。
gpconfig --skipvalidation 覆盖gpconfig的系统验证检查，并允许用户对任何服务器配置参数进行操作，包括隐藏参数和gpconfig无法更改的受限参数。当与-l选项（列表）一起使用时，它显示受限参数的列表。 警告： 使用此选项设置配置参数时要格外小心。
gpconfig --verbose 在gpconfig命令执行期间显示额外的日志信息。
gpconfig --debug 设置日志输出级别为调试级别。
gpconfig -? | -h | --help 显示在线帮助。


--gpstart
命令     参数   作用 
gpstart -a => 快速启动|
gpstart -d => 指定数据目录（默认值：$MASTER_DATA_DIRECTORY）
gpstart -q => 在安静模式下运行。命令输出不显示在屏幕，但仍然写入日志文件。
gpstart -m => 以维护模式连接到Master进行目录维护。例如：$ PGOPTIONS='-c gp_session_role=utility' psql postgres
gpstart -R => 管理员连接
gpstart -v => 显示详细启动信息


--gpstop
命令     参数   作用 
gpstop -a => 快速停止
gpstop -d => 指定数据目录（默认值：$MASTER_DATA_DIRECTORY）
gpstop -m => 维护模式
gpstop -q => 在安静模式下运行。命令输出不显示在屏幕，但仍然写入日志文件。
gpstop -r => 停止所有实例，然后重启系统
gpstop -u => 重新加载配置文件 postgresql.conf 和 pg_hba.conf
gpstop -v => 显示详细启动信息
gpstop -M fast      => 快速关闭。正在进行的任何事务都被中断。然后滚回去。
gpstop -M immediate => 立即关闭。正在进行的任何事务都被中止。不推荐这种关闭模式，并且在某些情况下可能导致数据库损坏需要手动恢复。
gpstop -M smart     => 智能关闭。如果存在活动连接，则此命令在警告时失败。这是默认的关机模式。
gpstop --host hostname => 停用segments数据节点，不能与-m、-r、-u、-y同时使用 


--集群恢复
命令     参数   作用 
gprecoverseg -a => 快速恢复
gprecoverseg -i => 指定恢复文件
gprecoverseg -d => 指定数据目录
gprecoverseg -l => 指定日志文件
gprecoverseg -r => 平衡数据
gprecoverseg -s => 指定配置空间文件
gprecoverseg -o => 指定恢复配置文件
gprecoverseg -p => 指定额外的备用机
gprecoverseg -S => 指定输出配置空间文件


--激活备库流程
命令     参数   作用 
gpactivatestandby -d 路径 | 使用数据目录绝对路径，默认：$MASTER_DATA_DIRECTORY
gpactivatestandby -f | 强制激活备份主机
gpactivatestandby -v | 显示此版本信息


--始化备Master
命令     参数   作用 
gpinitstandby -s 备库名称 => 指定新备库
gpinitstandby -D => debug 模式
gpinitstandby -r => 移除备用机


--计算目前gp使用了多少内存 ,跟机器物理内存比较,大小不能超过物理内存总量-操作系统运行需要的最低内存
shared_buffers + max_connections*(work_mem+temp_buffers)


Pivotal Greenplum Command Center (GPCC) V4已经正式发布


Pivotal query optimizer (ORCA) 生成查询计划的时间开销高于旧的优化器，也就是说对小查询（毫秒级别的查询）性能会变差。
如果用户使用单行 Insert 的方式插入数据，建议变更加载数据的方式，使用 COPY 命令批量加载。


--postgre 系统表
pg_aggregate		聚集函数
pg_am				索引访问方法
pg_amop				访问方法操作符
pg_amproc			访问方法支持过程
pg_attrdef			字段缺省值
pg_attribute		表的列(也称为"属性"或"字段")
pg_authid			认证标识符(角色)
pg_auth_members		认证标识符成员关系
pg_autovacuum		每个关系一个的自动清理配置参数
pg_cast				转换(数据类型转换)
pg_class			表、索引、序列、视图("关系")
pg_constraint		检查约束、唯一约束、主键约束、外键约束
pg_conversion		编码转换信息
pg_database			本集群内的数据库
pg_depend			数据库对象之间的依赖性
pg_description		数据库对象的描述或注释
pg_index			附加的索引信息
pg_inherits			表继承层次
pg_language			用于写函数的语言
pg_largeobject		大对象
pg_listener			异步通知
pg_namespace		模式
pg_opclass			索引访问方法操作符类
pg_operator			操作符
pg_pltemplate		过程语言使用的模板数据
pg_proc				函数和过程
pg_rewrite			查询重写规则
pg_shdepend			在共享对象上的依赖性
pg_shdescription	共享对象上的注释
pg_statistic		优化器统计
pg_tablespace		这个数据库集群里面的表空间
pg_trigger			触发器
pg_type				数据类型
--postgre 系统视图
pg_cursors				打开的游标
pg_group				数据库用户的组
pg_indexes				索引
pg_locks				当前持有的锁
pg_prepared_statements	预备语句
pg_prepared_xacts		预备事务
pg_roles				数据库角色
pg_rules				规则
pg_settings				参数设置
pg_shadow				数据库用户
pg_stats				规划器统计
pg_tables				表
pg_timezone_abbrevs		时区缩写
pg_timezone_names		时区名
pg_user					数据库用户
pg_views				视图


--gp COPY命令
copy ttpai_boss_demension."BOSS_PHONE_RELATIVE" to '/opt/websuite/BOSS_PHONE_RELATIVE.txt' WITH DELIMITER AS ',';
