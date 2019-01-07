#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../ruby/attributes/default.bash"

export EC2_AMI_TOOLS_DOWNLOAD_URL='http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.zip'

export EC2_AMI_TOOLS_INSTALL_FOLDER_PATH='/opt/aws/ec2-ami-tools'
export EC2_AMI_TOOLS_RUBY_INSTALL_FOLDER_PATH="${RUBY_INSTALL_FOLDER_PATH}"