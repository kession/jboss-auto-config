jboss-auto-config(JAC)
=================

>一个JBOSS配置文件切换工具

## 使用场景

当开发多个java web工程时且没有热部署时，往往我们需要将多个工程进行编译将war包配置写在JBOSS并重启JBOSS，可能需要在多个配置文件（jboss-service.xml）间切换，jboss-auto-config(JAC)小工具可以帮助你进行切换，重启JBOSS.

## 功能列表

+ 可以用JAC切换预选设置好的配置文件
+ 可以设置好WAR包路径自动生成配置文件并替换
+ 可以一键mvn install并且启动JBOSS

## 运行示例

	 --------------------
	 < JBOSS Auto Config.  >
	 --------------------
	        \   ^__^
	         \  (oo)\_______
	            (__)\       )\/
	                ||----w |    
	                ||     ||    
	============================
	1) 使用预置的配置文件
	2）使用模板配置文件
	3) 编译打包并重启JBOSS
	4) 编译打包
	5) 启动JBOSS
	6) 帮助
	============================
	Enter your choose: 6


## 使用方法

+ 赋执行权限 `chmod a+x jboss-auto-conf.sh`
+ 运行： `./jboss-auto-conf.sh`

## 说明

+ 1) 使用预置的配置文件
   conf目录是用户预置的配置文件目录，用户需要保证配置文件正确。
   工具会自动将用户选择的文件替换JBOSS中的`/server/default/conf`的`jboss-service.xml`。

+ 2）使用模板配置文件
   用户配置好war包路径（可以多个）,程序会自己配置好`jboss-service.xml`文件。

+ 3) 编译打包并重启JBOSS
   `mvn clean install` + `run jboss`

+ 4) 编译打包
   only mvn clean install

+ 5) 启动JBOSS
   run jboss
