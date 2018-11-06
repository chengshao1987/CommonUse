--查看目录
dir
--回到上级目录
cd ..
--查看所有运行的端口
netstat -ano
--查看某个端口是否被占用
netstat -ano|find "8888"


--执行同级目录某个文件夹下面的命令
..\bin\syadmin --engine corp-000 create-sym-tables

--命令行进入服务
services.msc

--命令行进入控制面板
control

--可以使用dos命令chcp查看dos环境编码
chcp