#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

tomcatDownloadURL='http://www.us.apache.org/dist/tomcat/tomcat-8/v8.0.12/bin/apache-tomcat-8.0.12.tar.gz'

tomcatInstallFolder='/opt/tomcat'
tomcatJDKInstallFolder="${jdkInstallFolder}"

tomcatServiceName='tomcat'

tomcatUserName='tomcat'
tomcatGroupName='tomcat'

tomcatAJPPort='8009'
tomcatCommandPort='8005'
tomcatHTTPPort='8080'
tomcatHTTPSPort='8443'