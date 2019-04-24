--临时切换成超级用户权限,目录还是现有用户的目录，
sudo -s

--切换用户但是不切换目录，su命令为切换成超级用户
su master

--切换用户并切换目录， su - 命令切换为超级用户
su - gpadmin

--查看本机ip
ip a


--查看当前目录
pwd


--返回上一级目录
cd ..
--返回用户主目录
cd  或 cd ~
--返回根目录
cd /


--从文件中查找指定文字的行,并从该处前两行开始显示输出
more +/BOSS_SIGNUP_CHENG fe.warn.log

--查看ip地址
ifconfig -a

--查看文件最后一百行
tail -100 be.INFO.log.20180830-180028

--查找指定文字并高亮显示
grep 629370   be.INFO.log.20180830-180028 --color=auto

--grep显示行数
grep -n 629608  be.INFO.log.20180830-180713 --color=auto

--grep查找指定文字，并显示前后5行
grep -C 5 10050659 BOSS_SIGNUP.txt --color=auto

--cat指定行数开始显示1000行
cat  be.INFO.log.20180830-180713 |tail -n +5778859|head -n 1000


--查找文件中包含 10.10.4.29和CARMODEL_MODEL_BASE 的行 并分页显示
cat gpdb-2018-12-19_000000.csv |grep 10.10.4.29 | grep CARMODEL_MODEL_BASE |more

--sed命令显示第5778859到5778888行
sed -n '5778859,5778888p'  be.INFO.log.20180830-180713



--【一】从第3000行开始，显示1000行。即显示3000~3999行

cat filename | tail -n +3000 | head -n 1000

--【二】显示1000行到3000行

cat filename| head -n 3000 | tail -n +1000

*注意两种方法的顺序

 
分解：

    tail -n 1000：显示最后1000行
    tail -n +1000：从1000行开始显示，显示1000行以后的
    head -n 1000：显示前面1000行

--【三】用sed命令

 sed -n '5,10p' filename 这样你就可以只查看文件的第5行到第10行。



--查看linux  IO
iostat -m 2

--查看mysqlbinlog
mysqlbinlog -vvv mysql-bin.000112|more

--全词匹配
mysqlbinlog -vvv mysql-bin.000069|grep -C 20 -w  BOSS_CHECK --color=auto


--Linux查看版本当前操作系统内核信息
uname -a

--Linux查看当前操作系统版本信息
cat /proc/version 

--查看redhat版本
cat /etc/redhat-release

--Linux查看cpu相关信息，包括型号、主频、内核信息等
cat /proc/cpuinfo


--1. 查看物理CPU的个数
cat /proc/cpuinfo |grep "physical id"|sort |uniq|wc -l
 
--2. 查看逻辑CPU的个数
cat /proc/cpuinfo |grep "processor"|wc -l
 
--3. 查看CPU是几核
cat /proc/cpuinfo |grep "cores"|uniq
 
--4. 查看CPU的主频
cat /proc/cpuinfo |grep MHz|uniq


--查看内存大小
 cat /proc/meminfo
 
--查看防火墙状态
service iptables status

--查看selinux状态   Security Enhanced Linux    SELinux主要作用就是最大限度地减小系统中服务进程可访问的资源（最小权限原则）。
/usr/sbin/sestatus -v 


--sudo命令用来以其他身份来执行命令
-b：在后台执行指令；
-h：显示帮助；
-H：将HOME环境变量设为新身份的HOME环境变量；
-k：结束密码的有效期限，也就是下次再执行sudo时便需要输入密码；。
-l：列出目前用户可执行与无法执行的指令；
-p：改变询问密码的提示符号；
-s<shell>：执行指定的shell；
-u<用户>：以指定的用户作为新的身份。若不加上此参数，则预设以root作为新的身份；
-v：延长密码有效期限5分钟；
-V ：显示版本信息。


--查看gpfdist服务
 ps -ef|grep gpfdist
 
 --将某个目录的文件复制到另外一个目录，并且改名
 cp samples/corp-000.properties  engines/sunserver-000.properties
 
 --复制文件夹
 cp -r  bireme-1.0.0 bireme-1.0.0_bak


 --修改文件权限 ，修改bin下面所有文件的权限
     chmod 755 bin/*

 */--查看端口占用
   netstat -tunpl
   
   --查看某个端口占用
   netstat -tunpl | grep 8888
   
   --查看端口占用的进程
   netstat -nap|grep 8888

   --删除进程61019
   kill -9 61019
   
   
   --查看文件中含有 stack字样的行
   more postgresql.conf |grep stack

   --查看系统的限制值,包括系统用户栈最大值等等
   ulimit -a
   
   --查看linux系统默认编码
   locale

   --退出当前用户
   exit
   
   --解压文件
   unzip symmetric-server-3.9.14.zip
   
   --强制递归删除文件夹symmetric，并且不提示
   rm -rf symmetric
   
   --查看有多少个磁盘及分区
   fdisk -l
   
   --df命令的功能是用来检查linux服务器的文件系统的磁盘空间占用情况。
   df -h

   --查看内存的方法
   cat /proc/meminfo  或者 更直观的查看内存的命令：free -m
   
   
   
   
   --查看gpdata下面所有文件占用空间
   du -sh ./gpdata/*
*/
   
      
   --查看gpdata下面所有文件占用空间,并排序取 前两/倒两 个文件
   du -sh gpdata/* |sort -rn|head -2
*/
   du -sh gpdata/* |sort -rn|tail -2
*/

	--查看redhat版本是7还是8
	cat /etc/redhat-release 
	
	--查看系统交换分区大小
	swapon -s
	
	--查看crontab的日志记录
	1.  linux
	看 /var/log/cron这个文件就可以，可以用tail -f /var/log/cron观察(不能用cat查看)
	2. mail任务
	在 /var/spool/mail/root 文件中，有crontab执行日志的记录，用tail -f /var/spool/mail/root 即可查看最近的crontab执行情况。
	
	--查看历史命令 包含snmp字样
	history |grep snmp

	--查看主机名
	hostname
	
	--查看日期和时间
	date

	--将文件用scp命令从172.16.2.15上面拷贝到10.10.4.81
	scp MONITOR_GUAZI_EQUITMENT.txt root@10.10.4.81:/tmp/gpfdist_data
	
	
	rsync用法
	
	--Vi 编辑器快捷键
	gg 文件开头
	G  文件末尾
	yy 复制整行
	p  粘贴
	dd 删除整行
	u  撤销上一次操作
	
	
	--查看两个文件是否是一致的,使用md5sum命令查看计算出来的结果是否一致
	md5sum DP_SUCCESS_KPI.txt