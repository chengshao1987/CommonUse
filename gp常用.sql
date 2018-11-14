--测试环境的配置
/etc/hosts  --这个文件用来指定hosts
10.10.4.81	gpmaster
10.10.4.82	gpseg01
10.10.4.83	gpseg02
10.10.4.84	gpseg03



--gp字段命名
 不能以数字开头
 
 --创建schema
  create schema ttpai_boss_demension;
  
 --删除schema
 drop schema ttpai_test cascade;

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


--gp查看全部参数
show all 

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

--查看主备节点是否正常运行,表中如果status字段有为d的,说明节点挂了
select * from gp_segment_configuration order by dbid






