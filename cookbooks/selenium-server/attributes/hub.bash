#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

seleniumserverDownloadURL='http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar'

seleniumserverInstallFolder='/opt/selenium-server/hub'
seleniumserverJDKInstallFolder="${jdkInstallFolder}"

seleniumserverServiceName='selenium-server-hub'

seleniumserverUserName='selenium'
seleniumserverGroupName='selenium'

seleniumserverPort='4444'