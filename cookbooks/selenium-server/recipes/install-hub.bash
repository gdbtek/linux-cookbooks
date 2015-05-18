#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${seleniumserverJDKInstallFolder:?}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${seleniumserverJDKInstallFolder}"
    fi
}

function install()
{
    local -r serverConfigData=(
        '__PORT__' "${seleniumserverPort}"
    )

    installRole 'hub' "${serverConfigData[@]}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/hub.bash"
    source "${appPath}/../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING HUB SELENIUM-SERVER'

    checkRequirePort "${seleniumserverPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"