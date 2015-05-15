#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export tomcatDownloadURL='http://www.us.apache.org/dist/tomcat/tomcat-8/v8.0.22/bin/apache-tomcat-8.0.22.tar.gz'

export tomcatInstallFolder='/opt/tomcat'
export tomcatJDKInstallFolder="${jdkInstallFolder}"

export tomcatServiceName='tomcat'

export tomcatUserName='tomcat'
export tomcatGroupName='tomcat'

export tomcatAJPPort='8009'
export tomcatCommandPort='8005'
export tomcatHTTPPort='8080'
export tomcatHTTPSPort='8443'