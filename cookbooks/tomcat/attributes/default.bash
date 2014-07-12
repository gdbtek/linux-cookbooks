#!/bin/bash

source "$(dirname "${0}")/../../jdk/attributes/default.bash" || exit 1

tomcatDownloadURL='http://www.us.apache.org/dist/tomcat/tomcat-8/v8.0.9/bin/apache-tomcat-8.0.9.tar.gz'

tomcatInstallFolder='/opt/tomcat'
tomcatJDKFolder="${jdkInstallFolder}"

tomcatServiceName='tomcat'

tomcatUID='tomcat'
tomcatGID='tomcat'

tomcatAJPPort=8009
tomcatCommandPort=8005
tomcatHTTPPort=8080
tomcatHTTPSPort=8443