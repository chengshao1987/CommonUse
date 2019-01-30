--登录mongo数据库,切换到安装目录bin
mongo.exe
--显示数据库列表
show dbs
 
--切换数据库
use linajia

--显示当前数据库中的集合(类似关系数据库中的表)
show collections：

--db.foo.find()：对于当前数据库中的collection集合进行数据查找（由于没有条件，会列出所有数据） 
 db.lianjia_test.find()
 
 
--导出成csv格式 切换到安装目录bin目录下
 mongoexport.exe -d lianjia -c lianjia_test -f region,href,name,style,area,orientation,decoration,elevator,floor,build_year,sign_time,unit_price,total_price,fangchan_class,school,subway  --type=csv -o aaa.csv
 
