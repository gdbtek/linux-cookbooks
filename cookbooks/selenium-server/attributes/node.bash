#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

seleniumserverDownloadURL='http://selenium-release.storage.googleapis.com/2.43/selenium-server-standalone-2.43.1.jar'

seleniumserverInstallFolder='/opt/selenium-server/node'
seleniumserverJDKInstallFolder="${jdkInstallFolder}"

seleniumserverServiceName='selenium-server-node'

seleniumserverUserName='selenium'
seleniumserverGroupName='selenium'

seleniumserverPort='5555'
seleniumserverHubPort='4444'
seleniumserverHubHost='selenium-private.ccmui.adobe.com'