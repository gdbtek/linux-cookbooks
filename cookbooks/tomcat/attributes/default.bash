#!/bin/bash

downloadURL='http://mirrors.advancedhosters.com/apache/tomcat/tomcat-8/v8.0.5/bin/apache-tomcat-8.0.5.tar.gz'

installFolder='/opt/tomcat'
jdkFolder='/opt/jdk'

serviceName='tomcat'

uid='tomcat'
gid='tomcat'

ajpPort=8009
commandPort=8005
httpPort=8080
httpsPort=8443
