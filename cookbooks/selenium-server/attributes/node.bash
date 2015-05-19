#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export seleniumserverDownloadURL='http://selenium-release.storage.googleapis.com/2.45/selenium-server-standalone-2.45.0.jar'

export seleniumserverInstallFolder='/opt/selenium-server/node'
export seleniumserverJDKInstallFolder="${JDK_INSTALL_FOLDER}"

export seleniumserverServiceName='selenium-server-node'

export seleniumserverUserName='selenium'
export seleniumserverGroupName='selenium'

export seleniumserverPort='5555'
export seleniumserverHubPort='4444'
export seleniumserverHubHost='selenium-private.ccmui.adobe.com'