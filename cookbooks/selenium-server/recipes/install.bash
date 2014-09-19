#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${seleniumserverJDKInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${seleniumserverJDKInstallFolder}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${seleniumserverInstallFolder}"

    # Install

    curl -L "${seleniumserverDownloadURL}" -o "${seleniumserverInstallFolder}"

    # Add User

    addUser "${seleniumserverUserName}" "${seleniumserverGroupName}" 'false' 'true' 'false'

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${seleniumserverInstallFolder}"
        '__JDK_INSTALL_FOLDER__' "${seleniumserverJDKInstallFolder}"
        '__USER_NAME__' "${seleniumserverUserName}"
        '__GROUP_NAME__' "${seleniumserverGroupName}"
    )

    createFileFromTemplate "${appPath}/../templates/default/selenium-server.conf.upstart" "/etc/init/${seleniumserverServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    chown -R "${seleniumserverUserName}:${seleniumserverGroupName}" "${seleniumserverInstallFolder}"
    start "${seleniumserverServiceName}"

    # Display Version

    info "\n$("${seleniumserverInstallFolder}/bin/version.sh")"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SELENIUM SERVER'

    checkRequirePort "${seleniumserverAJPPort}" "${seleniumserverPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"