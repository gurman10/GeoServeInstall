q#!/bin/bash

#Saves file descriptors so they can be restored to whatever they were before redirection or used themselves to output to whatever they were before the following redirect.
exec 3>&1 4>&2
#Restore file descriptors for particular signals. Not generally necessary since they should be restored when the sub-shell exits.
trap 'exec 2>&4 1>&3' 0 1 2 3
#Redirect stdout to file log.out then redirect stderr to stdout. Note that the order is important when you want them going to the same file. stdout must be redirected before.
exec 1>log.out 2>&1

#Assumption
#Default shell is #!/usr/bin/env bash
#

#Set the location to download zip files for server and dependencies
downloadLocation="/private/tmp"

#Set the location to installl GeoServer at
geoInstallLocation="opt/GeoServer"

#Get the Binary file from web
#curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/2.21.1/geoserver-2.21.1-bin.zip -o /Users/gusingh/Downloads/geoserver-2.21.1-bin.zip

curl -L -o "${downloadLocation}/GeoServer.zip" https://sourceforge.net/projects/geoserver/files/GeoServer/2.21.1/geoserver-2.21.1-bin.zip


#Extarct it to the locatiion of installation




#Download to Downloads with name jre.pkg
curl -L -o "${downloadLocation}/jre.pkg" https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.16.1%2B1/OpenJDK11U-jre_aarch64_mac_hotspot_11.0.16.1_1.pkg

#Install jre and reboot
installer -pkg ~/Downloads/jre.pkg -target CurrentUserHomeDirectory

#Set path variable
export JAVA_HOME=`/usr/libexec/java_home`

#Set GEOSERVER_HOME
