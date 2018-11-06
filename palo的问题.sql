1 建分区和桶之后,如果要删除表里面的所有数据，要drop掉表，然后重建表(而其他数据库的做法是有truncate语句，直接删除，不影响原来的表结构)
2 2-70-116-128这种字符串palo里面没有相关的字符串函数分割，然后取第几个，其他数据库有相关的函数。BOSS_SIGNUP中渠道字段source 字段没有按照固定长度比如 2-70-116-128，渠道有可能是三个  2-70-116 或者 两个 2-70 或者一个  2这种类型，使用现有的语句regexp_extract(tt.source,'(.*)-(.*)-(.*)-(.*)',4)导致有些渠道分割不出来，改造语句，使其能适应现有的情况。
3 palo建表语句比较慢，BOSS_SIGNUP表改造时，耗时比较长，按照年分区，8个分区，从14年到2020年,16个分桶，建表语句花了7分20秒
4 没有存储过程的功能，无法写存储过程夜间跑批，将结果跑出来，供白天查询
5 查表的话貌似有字段限制,如果字段很多，直接显示lost connection
6 不能复制整个数据库到另外一个数据库
7 不支持：palo可以支持建事实表的时候指定某一列的值是根据其他几个指标列按照某种公式计算出来的结果吗？类似现在的agg_type聚合类型列，只不过目前的聚合列不能跨列计算？
8 不支持单条DELETE的删除，不支持DELETE FROM BOSS_ACCOUNT_BAK   WHERE ID =21 支持 DELETE FROM BOSS_ACCOUNT_BAK PARTITION BOSS_ACCOUNT_BAK  WHERE id =59
9 不支持insert into values 这种形式，只支持 insert into select 这种形式
Delete
该语句用于按条件删除指定table（base index） partition中的数据。该操作会同时删除和此相关的rollup index的数据。

语法：

 DELETE FROM table_name PARTITION partition_name WHERE   
 column_name1 op value[ AND column_name2 op value ...];
说明：

op的可选类型包括：=, <, >, <=, >=, !=

只能指定key列上的条件。

条件之间只能是“与”的关系。若希望达成“或”的关系，需要将条件分写在两个 DELETE语句中。

如果没有创建partition，partition_name 同 table_name。

注意：

该语句可能会降低执行后一段时间内的查询效率，影响程度取决于语句中指定的删除条件的数量，指定的条件越多，影响越大。

10 有些表update语句没有成功,张天龙问过强哥，说是Palo的bug，升级Palo的版本之后再看。。
11 将一张表insert到另一张表的时候，目标表的字段，源表没有的字段，不能简单的用NULL值替换，不然insert不成功，要给int类型和varchar类型一个默认值
