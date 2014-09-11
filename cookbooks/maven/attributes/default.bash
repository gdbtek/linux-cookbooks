#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

mavenDownloadURL='http://www.us.apache.org/dist/maven/maven-3/3.2.3/binaries/apache-maven-3.2.3-bin.tar.gz'

mavenInstallFolder='/opt/maven'
mavenJDKInstallFolder="${jdkInstallFolder}"