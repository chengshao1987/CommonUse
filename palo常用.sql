--palo在linux上的目录
/opt/websuite/palo-fe/conf

--palo表名区分大小写，字段名不区分
select * from boss_city  报错
select * from BOSS_CITY

select id,city_name,is_flag,name_index from BOSS_CITY
等同于  select ID,CITY_NAME,IS_FLAG,NAME_INDEX from BOSS_CITY

--palo注释
SELECT * FROM BOSS_CITY  -- THIS IS A COMMNET

--日期格式化
SELECT DATE_FORMAT(NOW() ,'%Y%m')


--palo cast
SELECT CAST('2017-07-01' AS DATE)
SELECT CAST('2017-07-01' AS DATETIME)

--字符串分割,取第N个子串
SELECT '188,55,162,798',regexp_extract('188,55,162,798','(.*),(.*),(.*),(.*)',2)



--palo 聚合类型
        agg_type：聚合类型，如果不指定，则该列为 key 列。否则，该列为 value 列
                            SUM、MAX、MIN、REPLACE、HLL_UNION(仅用于HLL列，为HLL独有的聚合方式)
                            该类型只对聚合模型(key_desc的type为AGGREGATE KEY)有用，其它模型不需要指定这个。
							
--palo的数据类型
Palo 的数据模型主要分为3类:
Aggregate		 --value列按照指定的聚合类型聚合，目前只支持SUM、MAX、MIN、REPLACE 四种类型
Uniq			 --key一样的value列直接覆盖，但是不支持rollup功能
Duplicate        --根据duplicate key 排序不做任何聚合


-- palo支持的insert

INSERT INTO `ttpai_boss_v1`.`BOSS_CITY2` 
SELECT * FROM `ttpai_boss_v1`.`BOSS_CITY` 

--palo支持的delete
DELETE FROM  `ttpai_boss_v1`.`BOSS_CITY2`  PARTITION `BOSS_CITY2`
WHERE id<300000

如果要删除分区表的整个表的数据的话,直接drop，然后重建表

--删除字段
 ALTER TABLE  `ttpai_boss_v1`.`BOSS_CITY2`
DROP COLUMN CITY_NAME 


--增加字段
ALTER TABLE `ttpai_boss_v1`.`BOSS_CITY2`
ADD COLUMN CITY_NAME3 VARCHAR(90)

--查看修改字段进度
SHOW ALTER TABLE COLUMN

--取消修改表结构
CANCEL ALTER TABLE COLUMN FROM `ttpai_boss_v1`.`BOSS_CITY2`

--修改value字段IP的类型,本来是INT,现在修改成BIGINT
ALTER TABLE BOSS_LOG
MODIFY COLUMN IP BIGINT REPLACE NOT NULL

--分析函数
SELECT tt.*,row_number() over (PARTITION BY success_auction_id ORDER BY  old_price  DESC ) rn FROM BOSS_AUCTION_DISTRIBUTE_BID tt
WHERE id<=100

--查看帮助
HELP 'load'  
HELP 'mini load'

--使用某个数据库
use ttpai_boss_v1

--创建表
CREATE TABLE IF NOT EXISTS expamle_tbl
(
	`user_id` LARGEINT NOT NULL COMMENT "用户id",
	`date` DATE NOT NULL COMMENT "数据灌入日期时间",
	`timestamp` DATETIME NOT NULL COMMENT "数据灌入的时间戳",
	`city` VARCHAR(20) COMMENT "用户所在城市",
	`age` SMALLINT COMMENT "用户年龄",
	`sex` TINYINT COMMENT "用户性别",
	`last_visit_date` DATETIME REPLACE DEFAULT "1970-01-01 00:00:00" COMMENT "用户最后一次访问时间",
	`cost` BIGINT SUM DEFAULT "0" COMMENT "用户总消费",
	`max_dwell_time` INT MAX DEFAULT "0" COMMENT "用户最大停留时间",
	`min_dwell_time` INT MIN DEFAULT "99999" COMMENT "用户最小停留时间"
)
ENGINE=olap
AGGREGATE KEY(`user_id`, `date`, `timestamp`, `city`, `age`, `sex`)
PARTITION BY RANGE(`date`)
(
	PARTITION `p201701` VALUES LESS THAN ("2017-02-01"),
	PARTITION `p201702` VALUES LESS THAN ("2017-03-01"),
	PARTITION `p201703` VALUES LESS THAN ("2017-04-01")
)
DISTRIBUTED BY HASH(`user_id`) BUCKETS 16
PROPERTIES
(
	"storage_type" = "COLUMN",
	"replication_num" = "3",
	"storage_medium" = "SSD",
	"storage_cooldown_time" = "2018-09-28 12:00:00"
);

--查看建表语句
SHOW CREATE TABLE BOSS_ACCOUNT



-- 该语句用于展示指定 table 的 schema 信息, 如果指定 ALL，则显示该 table 的所有 index 的 schema
DESC BOSS_CITY ALL


--查看分区
SHOW PARTITIONS FROM expamle_tbl


--查看执行计划
EXPLAIN SELECT * FROM BOSS_CITY


--创建rollup
ALTER TABLE BOSS_CITY
ADD ROLLUP boss_city_rollup1(id,name_index,city_name,is_flag) FROM BOSS_CITY
PROPERTIES("storage_type" = "COLUMN");

--删除rollup
ALTER TABLE BOSS_CITY
DROP ROLLUP boss_city_rollup1;

--查看已有的rollup
DESC BOSS_CITY ALL



--展示指定 db 的创建或删除 ROLLUP index 的任务执行情况
 SHOW ALTER TABLE ROLLUP FROM ttpai_boss_v1;

--展示默认 db 的所有修改列的任务执行情况
 SHOW ALTER TABLE COLUMN;


--mini load  默认是tab键分割字段 \t
curl --location-trusted -u root:ttpai -T demo1.txt http://172.16.4.57:80/api/ttpai_boss_v1/table1/_load?label=table1_20180823

--查看BE状态

使用 mysql-client 连接到 FE，并执行 SHOW PROC '/backends'; 查看 BE 运行情况。如一切正常，isAlive 列应为 true。

--目前三个库





Palo Schema Change：Palo支持Online Schema Change。
所谓的Schema在线变更就是指Scheme的变更不会影响数据的正常导入和查询，Palo中的Schema在线变更有3种：
direct schema change：就是重刷全量数据，成本最高，和kylin的做法类似。当修改列的类型，稀疏索引中加一列时需要按照这种方法进行。
sorted schema change: 改变了列的排序方式，需对数据进行重新排序。例如删除排序列中的一列, 字段重排序。
linked schema change: 无需转换数据，直接完成。对于历史数据不会重刷，新摄入的数据都按照新的Schema处理，对于旧数据，新加列的值直接用对应数据类型的默认值填充。例如加列操作。Druid也支持这种做法。









不支持，目前只能将mysql中的数据 dump 成文本文件进行导入





@imay 您好，最近提了一些问题，非常感谢您的回答。

我目前根据palo支持的两种导数据的方式对于数据实时导入只能提出如下的解决方案：

1、对于hdfs的文件，有分区字段，设置一个定时脚本使用pull load方案将数据导入
2、对于mysql中的数据，无分区字段，事先创建一个mysql的外部表，然后设置一个定时脚本执行insert into table ... select ... from 方式将mysql中的数据导入到palo中，每次定时脚本执行前先清空原来的palo表。
实际上，我认为第一种针对于hdfs的数据的导入方式还算合理，但是第二种针对于mysql中的数据的导入方式就不太合理了。

请问在使用Palo时对于需要实时增量加载数据的应用场景有没有好的解决方案。



对于从MySQL定期导入增量数据到Palo中，可以使用工具从MySQL定期同步更新数据，然后使用mini load方式导入到Palo中。
Palo在1-2个月内就会发布流式导入版本，届时导入的时效性会有一定提升



可以创建一个MySQL外部表，help create table里面有说明。
然后通过insert...select方式来完成导入Palo表


大神，如果我用canal+mq的方式做增量导入palo是否可以？


--有空的时候看下GP集群的安装教程
--有空看下canal的原理


