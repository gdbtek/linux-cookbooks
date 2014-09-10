#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

jenkinsWorkspaceFolder='/opt/jenkins'

jenkinsJDKInstallFolder="${jdkInstallFolder}"

jenkinsUserName='root'
jenkinsGroupName='root'