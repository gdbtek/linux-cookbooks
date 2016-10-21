#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export ANT_DOWNLOAD_URL='http://www.us.apache.org/dist//ant/binaries/apache-ant-1.9.7-bin.tar.gz'

export ANT_INSTALL_FOLDER='/opt/ant'
export ANT_JDK_INSTALL_FOLDER="${JDK_INSTALL_FOLDER}"