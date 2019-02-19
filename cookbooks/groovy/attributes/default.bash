#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export GROOVY_DOWNLOAD_URL='https://dl.bintray.com/groovy/maven/apache-groovy-binary-2.5.6.zip'

export GROOVY_INSTALL_FOLDER_PATH='/opt/groovy'
export GROOVY_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"