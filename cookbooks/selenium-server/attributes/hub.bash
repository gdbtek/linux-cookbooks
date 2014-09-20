#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

seleniumserverDownloadURL='http://selenium-release.storage.googleapis.com/2.43/selenium-server-standalone-2.43.1.jar'

seleniumserverInstallFolder='/opt/selenium-server/hub'
seleniumserverJDKInstallFolder="${jdkInstallFolder}"

seleniumserverServiceName='selenium-server-hub'

seleniumserverUserName='selenium'
seleniumserverGroupName='selenium'

seleniumserverPort=4444