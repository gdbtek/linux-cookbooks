#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export jenkinsWorkspaceFolder='/opt/jenkins'

export jenkinsJDKInstallFolder="${jdkInstallFolder:?}"

export jenkinsUserName='root'
export jenkinsGroupName='root'