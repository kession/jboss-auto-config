#! /bin/bash

# jboss-auto-config(JAC)

# 一个JBOSS切换配置文件工具
# @author kession
# @github https://github.com/kession
# @fork   https://github.com/kession/jboss-auto-config

#  设置相关配置
# ------------------------------------------设置相关配置开始--------------------------------------------------

# JBOSS根目录
JBOSS_HOME="/home/kession/softs/jboss-4.2.2.GA"

# svn分支工程目录，可以多个，用于mvn install
WORKSPACE=("/home/kession/workspace/test1/test1-webapp" 
	"/home/kession/workspace/test1/test2-webapp")

# war包路径，用于生成模板配置文件
WAR=("/home/kession/workspace/test1/test1-webapp/target/tanx-crm.war" 
"/home/kession/workspace/test1/test2-webapp/target/tanx-crm.war" )

# ------------------------------------------设置相关配置结束--------------------------------------------------

# JBOSS配置文件路径
JBOSSConfDir=${JBOSS_HOME}"/server/default/conf"

# JBOSS bin路径
JBOSSBinDir=${JBOSS_HOME}"/bin"

clear 


function help {
cat << EOF
-----------------------------------------------------------------------------
说明：
1) 使用预置的配置文件
   conf目录是用户预置的配置文件目录，用户需要保证配置文件正确。
   工具会自动将用户选择的文件替换JBOSS中的/server/default/conf的jboss-service.xml。
2）使用模板配置文件
   用户配置好war包路径（可以多个）,程序会自己配置好jboss-service.xml文件。
3) 编译打包并重启JBOSS
   mvn clean install + run jboss
4) 编译打包
   only mvn clean install
5) 启动JBOSS
   run jboss
6) 帮助
-----------------------------------------------------------------------------

EOF
pause
main
}

# continue
function get_char() {
   SAVEDSTTY=`stty -g`
   stty -echo
   stty raw
   dd if=/dev/tty bs=1 count=1 2> /dev/null
   stty -raw
   stty echo
   stty $SAVEDSTTY
}

function pause() {
	echo "Press any key to continue..."
	char=`get_char`
}


# 检查配置是否正确
function checkSetting() {
        # 检查JBOSS配置
	if [[ -z "WORKSPACE" || -z "$JBOSS_HOME" || ! -d "$JBOSS_HOME" || ! -d "$JBOSSConfDir" ]] ; then
		echo " The dir $JBOSS_HOME is NOT exist."
		echo "Enter to exit... "
		read
		exit 1
	fi
        
        # 检查工程目录是否存在
	for target in ${WORKSPACE[@]} ; do
		if [[ ! -d "$target" ]] ; then
			echo "============The following dir is not exist.============"
			echo "$target"
			echo "======================================================="
			echo "Enter to exit... "
			read
			exit 1
		fi
	done
}

# 替换配置文件
function replaceConfFile() {
	oldConf=$JBOSSConfDir"/jboss-service.xml"
	newConf=$1
	echo "删除当前 JBOSS 配置文件.."
	rm -f $oldConf
	echo "开始替换： $oldConf -----> $newConf  '"
	cp $newConf $oldConf
	echo "替换成功! Success!"

}



function main() {	
cat << EOF
 --------------------
 < JBOSS Auto Config.  >
 --------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\

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
EOF

	# 读取输入
	read -p "Enter your choose: " input
	case $input in 
	    	1) preConfigure ;;
	    	2) templateConf;;
            3) autoReboot 1;;   # mvn install + run jboss
            4) autoReboot 2 ;;  # mvn install
            5) rebootJboss ;;  # run jboss
            6) help ;;
        *) echo 'Invaild Input...' 
			pause
           	main
           ;;
	esac
	pause
	main

}

# 1) 替换配置文件
function preConfigure() {
        # 读取conf文件夹下配置文件
        echo 'Reading conf folder.'
        if test -d "./conf" 
        then
           i=0
           for conf in ./conf/*.xml
           do
              array[$i]=$conf
              let "i+=1"
           done
        else
           echo 'n'
        fi
        
        # 配置文件数量
        num=${#array[@]}

        # 判断是否有配置文件
        if [ $num -le 0 ]
        then        
           echo "Not any xml file to be found."
        else
           echo "Found $num files. "

           # 列出所有配置文件供选择
           i=0
           echo "-------------------------------------------------------------------"
           for f in ${array[@]}
           do
              echo "$i) $f"  
              let "i+=1"
           done
           echo "-------------------------------------------------------------------"
           read -p "Please take your choose:" confIndex

           # 输入检查           
           case $confIndex in 
                [0-9]*)
                      echo "You choose ${array[$confIndex]}" 
                      replaceConfFile "${array[$confIndex]}"
                      ;;
                    *)
                      echo "Wrong Input."$confIndex 
                      pause
                      main
                      ;;
           esac
         fi
}

#2 templateConf

function templateConf() {
	# 列出所有war
	i=0
	echo "-------------------------------------------------------------------"
	for f in ${WAR[@]}
	do
	  echo "$i) $f"  
	  let "i+=1"
	done
	echo "-------------------------------------------------------------------"
	read -p "Please take your choose:" warIndex

	# 输入检查           
	case $warIndex in 
	    [0-9]*)
	          echo "You choose ${WAR[$warIndex]}" 
	          if [[ ! -f "${WAR[$warIndex]}" ]] ; then
	          	echo "Can not find any war package."
	          	pause
	          	main
	          fi
	          replaceWarPath "${WAR[$warIndex]}"
	          ;;
	        *)
	          echo "Wrong Input."$warIndex 
	          pause
	          main
	          ;;
	esac	

}

function replaceWarPath {
	if [[ ! -f "./jboss-service-template.xml" ]] ; then
		echo "Where is my template file."
		pause
		main
	fi
	rm -f ./jboss-service-template.xml.new
	cp ./jboss-service-template.xml ./jboss-service-template.xml.new
	sed -i "s#=war path here=#$1#" ./jboss-service-template.xml.new
	replaceConfFile "./jboss-service-template.xml.new"
	rm -f ./jboss-service-template.xml.new
}
# 2) 编译工程并重启Jboss
function maveninstall {	
	cd $1
	echo "-------------------Start-to-combile---------------------------"
	mvn clean install -Dmaven.test.skip=true
	echo "--------------------End-to-combile----------------------------"
	
}

function rebootJboss {
	echo "--------------------Rebooting JBOSS----------------------------"
	cd $JBOSSBinDir
	./run.jar
	echo "--------------------Reboot JBOSS Done----------------------------"
}



function autoReboot {
	# 列出所有工程
	i=0
	echo "-------------------------------------------------------------------"
	for f in ${WORKSPACE[@]}
	do
	  echo "$i) $f"  
	  let "i+=1"
	done
	echo "-------------------------------------------------------------------"
	
	read -p "Please take your choose:" projIndex

	# 输入检查           
	case $projIndex in 
	    [0-9]*)
	          echo "You choose ${WORKSPACE[$projIndex]}" 
	          case $1 in 
	          	1) maveninstall "${WORKSPACE[$projIndex]}"
				   rebootJboss
				   ;;
				2) maveninstall "${WORKSPACE[$projIndex]}" 
				   ;;
				*) main ;;
			   esac
			   ;;
	        *)
	          echo "Wrong Input."$projIndex 
	          pause
	          main
	          ;;
	esac
}


checkSetting
main


