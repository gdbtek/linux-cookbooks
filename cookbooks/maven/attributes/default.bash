#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export mavenDownloadURL='http://www.us.apache.org/dist/maven/maven-3/3.3.1/binaries/apache-maven-3.3.1-bin.tar.gz'

export mavenInstallFolder='/opt/maven'
export mavenJDKInstallFolder="${jdkInstallFolder}"