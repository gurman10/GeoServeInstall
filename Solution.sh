#!/bin/bash


log="${HOME}/Downloads/GeoInstallLogs.txt"

#Saves file descriptors so they can be restored to whatever they were before redirection or used themselves to output to whatever they were before the following redirect.
exec 3>&1 4>&2
#Restore file descriptors for particular signals. Not generally necessary since they should be restored when the sub-shell exits.
trap 'exec 2>&4 1>&3' 0 1 2 3 RETURN
#Redirect stdout to file log.out then redirect stderr to stdout. Note that the order is important when you want them going to the same file. stdout must be redirected before.
exec 1>>$log 2>&1

#Assumption
#Default shell is #!/usr/bin/env bash

#Set the location to download zip files for GeoServer
geoDownLocation="${HOME}/Downloads/GeoServer.zip"
#Set the location to install GeoServer
geoInstallLocation="${HOME}/Downloads/GeoServer"


#Set the location to download zip files for JRE 11 package
jreDownLocation='${HOME}/Downloads/jre.pkg'

geoServerLink='https://sourceforge.net/projects/geoserver/files/GeoServer/2.21.1/geoserver-2.21.1-bin.zip'
jreLink="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.16.1%2B1/OpenJDK11U-jre_aarch64_mac_hotspot_11.0.16.1_1.pkg"


#Function to download a file from web. $1 is the directory path where file is be stored locally
#And $2 is the download link
download_from_web(){
	date
	echo "-------------------------------------------------------------------------------"
	curl -L -o $1 $2
	echo "-------------------------------------------------------------------------------"
	if [[ $? -eq 0 ]] && [[ -a $1 ]]
	then
		date
		echo ">>File has been downloaded to ${1}"
	else
		date
		echo ">>Could not download the file from the specified link"
	fi
	printf "\n<<<<<<<<<<<<<<<<<<-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
}


#Returns 0 if Java 11 is installed otherwise returns 1
is_java_11_installed(){
	#check if java executable exits in the path
	if type -p java
	 then
	 	echo Found java executable in PATH
	 	_java=java
	#check JAVA_HOME in not null and file exists and is executable
	 elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]
	  then
	  	echo Found java executable in JAVA_HOME
	  	_java="$JAVA_HOME/bin/java"
	 else
	 	return 0
	fi

	if [[ "$_java" ]]
	 then
	 	version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
	 	echo version "$version"
	 	if [[ "$version" == "11.0.16.1" ]]
	 	 then
	 	 	return 0
	 	 else         
	 	 	return 1
	 	 fi
	fi
}


#If GeoServer.zip file doesn't exist at the download location download from web
if [[ ! -a $geoDownLocation ]]
 then
	printf "\n<<<<<<<<<<<<<<<Starting GeoServer download from web...>>>>>>>>>>>>>>>>>>>>>>>>\n"
	download_from_web $geoDownLocation $geoServerLink
fi


#If GeoServer directoty doesn't exist at the installtion location extract it there
if [[ ! -d $geoInstallLocation ]]
 then
 	unzip -q $geoDownLocation -d $geoInstallLocation
 	echo ">>File has been extracted to following location ${geoInstallLocation}"
fi


#If Java Runtime Environment 11 doesn't exist install it
if [[ is_java_11_installed = 1 ]]
 then
	printf "\n<<<<<<<<<<<<<<<Starting JRE 11 Package download from web...>>>>>>>>>>>>>>>>>>>>>>>>\n"
	download_from_web $jreDownLocation $jreLink
	#Install jre and reboot
	if [[ -a $jreDownLocation ]]
	 then
		installer -pkg $jreDownLocation -target CurrentUserHomeDirectory
		printf "Java Run Environment 11 has been installed.\n Reboot the system and run the Solution.sh file again to complete GeoServer installation\n" >&3
	fi
fi

#Set Environment variables
echo export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-11.jre/Contents/Home >> ~/.bash_profile
echo export GEOSERVER_HOME=$geoInstallLocation >> ~/.bash_profile
source ~/.bash_profile

#Start localhost server
bash "${geoInstallLocation}/bin/startup.sh"

echo "GeoServer Installation logs saved at ${HOME}/Downloads/GeoInstallLogs.txt" >&3
printf "End of File\n\n"

exit 0