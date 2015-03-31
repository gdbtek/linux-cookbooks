#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../ruby/attributes/default.bash"

export ec2amitoolsDownloadURL='http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools-1.5.6.zip'
export ec2amitoolsInstallFolder='/opt/aws/ec2-ami-tools'

export ec2amitoolsRubyInstallFolder="${rubyInstallFolder}"