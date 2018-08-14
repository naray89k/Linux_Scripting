#! /bin/bash

# reset the shell 'SECONDS' variable to zero seconds.
SECONDS=0

# sourcing the path variables in INI file
#source WAS_ENV_PROPS.ini

# GLOBAL VARIABLES
SCRIPTNAME=$(basename $0)
SCRIPTDIR=$(dirname $0)
source $SCRIPTDIR/mail_props.ini
LOGNAME="$SCRIPTDIR/${SCRIPTNAME%.*}.html"
PROFILE_BASE="/opt/pai/IBM/WebSphere/Profiles"
profiles=''
[ -d $PROFILE_BASE ] && profiles=(`ls $PROFILE_BASE`)
STATUS="FAILURE"
declare -A servers
WAS_BASE="/opt/pai/IBM/WebSphere"
IHS_BASE="/opt/pai/IBM/HTTPServer"
SERVERTYPE=''
[ -d $WAS_BASE ] && [ -d $IHS_BASE ] && SERVERTYPE="MIXED"
[ -d $WAS_BASE ] && [ ! -d $IHS_BASE ] && SERVERTYPE="APP"
[ ! -d $WAS_BASE ] && [ -d $IHS_BASE ] && SERVERTYPE="WEB"
[ -z ${1+x} ] && ENVNAME=$HOSTNAME
[ -z ${1+x} ] || ENVNAME=$1
flag=0


#dateFormat="+%d-%m-%Y %H:%M:%S"
exec 1>$LOGNAME
exec 2>&1
echo "<!DOCTYPE html>"
echo "<html>"
echo "<body>"
echo "<p>"
echo `date "+%d-%m-%Y %H:%M:%S"`" [STARTED]<br/>"

#echo ""
#echo ""

# This is to find the time taken for the execution of the script
elasped_time(){
	SEC=$1
	(( SEC < 60 )) && echo -e "[Elasped time: $SEC seconds]\c" 
	(( SEC >= 60  &&  SEC < 3600 )) && echo -e "[Elasped time: $(( SEC / 60 )) min $(( SEC % 60 )) sec]\c"
	(( SEC > 3600 )) && echo -e "[Elasped time: $(( SEC / 3600 )) hr $(( (SEC % 3600) / 60 )) min $(( (SEC % 3600) % 60 )) sec]\c"
	echo ""
}


# Exit Function
exit_script(){
	subject="${ENVNAME}-${SERVERTYPE}_SERVER-STATUS"
	if [ -z ${1+x} ]
		then
		subject="$subject-FAILURE"
		#mailx -S smtp=$SMTP_HOST -r $SENDER -s $subject $TOADDR < $LOGNAME
		#perl $SCRIPTDIR/sendMail.pl $SMTP_HOST $SENDER $TOADDR $subject $LOGNAME
	else
		subject=$subject"-"$1 
	fi
	#echo $subject
	echo ""
	echo `date "+%d-%m-%Y %H:%M:%S"`" [END]<br/>"
	echo "</p>"
	elasped_time $SECONDS
	echo '</body>'
	echo ""
	echo '</html>'
	#exec 1>/dev/tty
	#exec 2>&1
	perl $SCRIPTDIR/sendMail.pl $SMTP_HOST $SENDER $TOADDR $subject $LOGNAME
	exit
	#echo mailx -S smtp=$SMTP_HOST -r $SENDER -s $subject $TOADDR < $LOGNAME
	#mailx -S smtp=$SMTP_HOST -r $SENDER -s $subject $TOADDR < $LOGNAME
}


appServer_status(){
	# This section exits the script if PAI java processes are not running
	pai_platform_status=$(ps ax | grep java | grep -v grep | wc -l)
	[ $pai_platform_status -eq 0 ] && echo '<h3><font color="'red'"><b>WEBSPHERE IS NOT RUNNING</b></font></h3><br/>'
	[ $pai_platform_status -eq 0 ] && flag=1 && STATUS="FAILURE" && return

	# This section gets the list of nodes and application servers present in ServerIndex files
	# present in various profiles.
	for profile in ${profiles[@]} 
	do
		nodeBase="${PROFILE_BASE}/${profile}/config/cells/iap/nodes"
		nodes=(`ls "${nodeBase}"`)
		for node in ${nodes[@]} 
		do
			serverIndex="${nodeBase}/${node}/serverindex.xml"
			for string in `perl -ne 'print "$1|$2\n" if /serverName=\"(.*?)\"\s+serverType=\"(.*?)\"/' $serverIndex` 
			do
				server=`echo $string | cut -d'|' -f1`
				serverType=`echo $string | cut -d'|' -f2`
				servers[$server]="${node}|${serverType}"
			done
		done
	done

	# This section checks the status of the Application Servers found in the previous
	# section and updates their details in the html file
	echo ""
	echo '<h4><font color="'blue'"><b>APPLICATION SERVERS/DMGR STATUS:</b></font></h4>'
	echo '<table border = "1" bordercolor="#696969">'
	echo '<tr><th>SERVERNAME</th><th>NODENAME</th><th>SERVERTYPE</th><th>STATUS</th></tr>'
	for i in "${!servers[@]}"; do
			count=`ps ax | grep java | grep -v grep | awk '{print $(NF-1)"  "$NF}' | grep -Eo "\<$i\>" 2>/dev/null | wc -l`
			node=`echo ${servers[$i]} | cut -d'|' -f1`
			srvrType=`echo ${servers[$i]} | cut -d'|' -f2`
			if [ $count -eq 0 ] && ( [ $srvrType = "DEPLOYMENT_MANAGER" ] || [ $srvrType = "NODE_AGENT" ] ) 
			then
				STATUS="FAILURE"
				flag=1
				echo "<tr><td>$i</td><td>$node</td><td>$srvrType</td><td bgcolor="'#FFE4C4'"><font color="'red'"><b>NOT RUNNING</b></font></td></tr>"
			elif [ $srvrType = "APPLICATION_SERVER" ] && [ $count -eq 0 ]; 
			then
				[ $flag -eq 0 ] && STATUS="WARNING";flag=1
				echo "<tr><td>$i</td><td>$node</td><td>$srvrType</td><td bgcolor="'#FFE4C4'"><font color="'red'"><b>NOT RUNNING</b></font></td></tr>"
			elif [ $count -eq 1 ] 
			then
				echo "<tr><td>$i</td><td>$node</td><td>$srvrType</td><td bgcolor="'#98FB98'"><font color="'green'"><b>RUNNING</b></font></td></tr>"
			fi
	done
	echo '</table>'
	echo '<br/>'
}
#Function 'appServer_status' ends here.


webServer_status(){
	webSrvr_status=$(ps ax | grep httpd | grep -v grep | wc -l)
	[ $webSrvr_status -eq 0 ] && echo '<h3><font color="'red'"><b>WEBSERVER IS NOT RUNNING</b></font></h3><br/>'
	[ $webSrvr_status -eq 0 ] && flag=1 && STATUS="FAILURE" && return

	if [ $webSrvr_status -gt 0 ]
		then
		echo ""
		echo '<h4><font color="'blue'"><b> WEBSERVER STATUS:</b></font></h4>'
		echo '<table border = "1" bordercolor="#696969">'
		echo '<tr><th>WEBSERVER STATUS</th><th>INSTANCES COUNT</th></tr>'
		echo "<tr><td bgcolor="'#98FB98'"><font color="'green'"><b>RUNNING</b></font></td><td>$webSrvr_status</td></tr>"
		echo '</table>'
	fi
}

case $SERVERTYPE in
MIXED)
	webServer_status
	echo '<hr>'
	appServer_status
	;;
APP)
	appServer_status
	;;
WEB)
	webServer_status
	;;
*)
	echo '<h4><font color="'red'"><b> BOTH APPLICATION & WEBSERVER IS NOT AVAILABLE </b></font></h3><br/>'
	STATUS="NONE"
	;;
esac

[ $flag -eq 0 ] && STATUS="SUCCESS"
exit_script $STATUS

