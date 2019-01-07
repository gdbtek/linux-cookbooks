#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export MAVEN_DOWNLOAD_URL='http://www.us.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz'

export MAVEN_INSTALL_FOLDER_PATH='/opt/maven'
export MAVEN_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"