#!/bin/bash


#Assumption
#Default shell is #!/usr/bin/env bash
#

#Get the Binary file from web
curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/2.21.1/geoserver-2.21.1-bin.zip -o ~/Downloads/sd.bin.zip

#Download to Downloads with name jre.pkg
curl -L https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.16.1%2B1/OpenJDK11U-jre_aarch64_mac_hotspot_11.0.16.1_1.pkg -o ~/Downloads/jre.pkg

#Install jre and reboot
installer -pkg ~/Downloads/jre.pkg -target CurrentUserHomeDirectory

#Set path variable
export JAVA_HOME=`/usr/libexec/java_home`

#Set GEOSERVER_HOME
