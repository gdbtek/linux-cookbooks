#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${seleniumserverJDKInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${seleniumserverJDKInstallFolder}"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/node.bash"
    source "${appPath}/../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NODE SELENIUM-SERVER'

    checkRequirePort "${seleniumserverPort}"

    installDependencies
    install 'node'
    installCleanUp

    displayOpenPorts
}

main "${@}"