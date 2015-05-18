#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export seleniumserverDownloadURL='http://selenium-release.storage.googleapis.com/2.45/selenium-server-standalone-2.45.0.jar'

export seleniumserverInstallFolder='/opt/selenium-server/hub'
export seleniumserverJDKInstallFolder="${jdkInstallFolder:?}"

export seleniumserverServiceName='selenium-server-hub'

export seleniumserverUserName='selenium'
export seleniumserverGroupName='selenium'

export seleniumserverPort='4444'