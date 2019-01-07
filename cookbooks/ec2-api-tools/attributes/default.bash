#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export EC2_API_TOOLS_DOWNLOAD_URL='http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip'

export EC2_API_TOOLS_INSTALL_FOLDER_PATH='/opt/aws/ec2-api-tools'
export EC2_API_TOOLS_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"