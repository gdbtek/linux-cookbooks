#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export MAVEN_DOWNLOAD_URL='http://www.us.apache.org/dist/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz'

export MAVEN_INSTALL_FOLDER='/opt/maven'
export MAVEN_JDK_INSTALL_FOLDER="${JDK_INSTALL_FOLDER}"