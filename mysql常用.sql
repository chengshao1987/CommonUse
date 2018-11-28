  --mysql查看版本
  SELECT VERSION()

  
  --显示字符集
  SHOW VARIABLES LIKE 'character%'

  
  --修改server字符集 win10
  C:\ProgramData\MySQL\MySQL Server 5.7\my.ini
  
  MySQL安装目录下的my.ini文件

 

[client]节点

#修改客户端默认字符编码格式为utf8

default-character-set=utf8    (增加)

 
[mysql]节点

default-character-set=utf8    (修改)

 

[mysqld]节点

#修改服务器端默认字符编码格式为utf8

default-character-set=utf8 (修改) 添加上服务启动出错 不用添加default-character-set

character_set_server=utf8    (增加) 



--查看表的数据量
USE information_schema
SELECT table_name,table_rows FROM TABLES ORDER BY table_rows DESC


--日期格式化 字符串转成日期
 SELECT DATE_FORMAT('2017-09-20 08:30:45',   '%Y-%m-%d %H:%i:%S');

 --日期格式化  日期转成字符串
 SELECT DATE_FORMAT(NOW(),   '%Y-%m-%d %H:%i:%S') 
 
 --字符串转成日期
 str_to_date('1970-01-01 00:00:00',   '%Y-%m-%d %H:%i:%S');
 
 
 --查看建表语句
SHOW CREATE TABLE BOSS_ACCOUNT

--查看安装目录
show variables like "%char%";

--mysql配置文件
/etc/my.conf

--查看指定库的指定表的大小
select concat(round(sum(DATA_LENGTH/1024/1024),2),'MB') as data  from TABLES where table_schema='jishi' and table_name='a_ya';

--mysql dump出表结构
 mysqldump -h172.16.2.187 -uroot -pbbb -d  --ignore-table=ttpai_boss_v1.BOSS_RECEPTION_DEPART_V ttpai_boss_v1 >C:\Users\test\Downloads\boss.sql

