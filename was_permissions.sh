#! /bin/bash

# reset the shell 'SECONDS' variable to zero seconds.
SECONDS=0

# sourcing the path variables in INI file
source WAS_ENV_PROPS.ini

# GLOBAL VARIABLES
logfile="epdmWAS_permissions.log"
flag=0


#dateFormat="+%d-%m-%Y %H:%M:%S"
exec 1>>$logfile
exec 2>&1
echo `date "+%d-%m-%Y %H:%M:%S"` [started]


# FUNCTIONS
# This function checks the availability/necessity to execute ownnership change function below.
# it  should be supplied with path,userid as arguments(in order)
check(){
	local fileCount=`find $1 ! \( -user $2 -o -group $3 \) |  wc -l`
	[ $fileCount -gt 0 ] && return 1
	[ $fileCount -eq 0 ] && return 0
}

# This function execute the ownnership change command below and
# it  should be supplied with path,userid,groupname as arguments(in order)
chng_Ownership(){
	echo "find $1 ! \( -user $2 -o -group $3 \) | xargs chown -Rc $2:$3"
	#find $1 \! -user $2 | xargs chown -Rc $2:$3
	find $1 \! -user $2 -exec chown -Rc $2:$3 {} \;
	flag=1
}

# This is to find the time taken for the execution of the script
elasped_time ()
{
	SEC=$1
	(( SEC < 60 )) && echo -e "[Elasped time: $SEC seconds]\c"
	(( SEC >= 60  &&  SEC < 3600 )) && echo -e "[Elasped time: $(( SEC / 60 )) min $(( SEC % 60 )) sec]\c"
	(( SEC > 3600 )) && echo -e "[Elasped time: $(( SEC / 3600 )) hr $(( (SEC % 3600) / 60 )) min $(( (SEC % 3600) % 60 )) sec]\c"
}

# MAIN SECTION
check $profBasePath $usr $grp
[ $? -eq 1 ] && chng_Ownership $profBasePath $usr $grp

check $profDmgrPath $usr $grp
[ $? -eq 1 ] && chng_Ownership $profDmgrPath $usr $grp

check $logBasePath $usr $grp
[ $? -eq 1 ] && chng_Ownership $logBasePath $usr $grp

check $logDmgrPath $usr $grp
[ $? -eq 1 ] && chng_Ownership $logDmgrPath $usr $grp

check $addOnPath $usr $grp
[ $? -eq 1 ] && chng_Ownership $addOnPath $usr $grp

check $jdbcDriverPath $usr $grp
[ $? -eq 1 ] && chng_Ownership $jdbcDriverPath $usr $grp

[ $flag -eq 0 ] && echo "Already, All the files in the required paths are owned by $usr"
echo `date "+%d-%m-%Y %H:%M:%S"` [end]
elasped_time $SECONDS
echo -e "\n"
