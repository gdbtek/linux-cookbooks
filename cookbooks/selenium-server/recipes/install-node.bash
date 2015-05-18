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
    local -r hubHost="${1}"

    # Override Default

    if [[ "$(isEmptyString "${hubHost}")" = 'false' ]]
    then
        seleniumserverHubHost="${hubHost}"
    fi

    checkNonEmptyString "${seleniumserverHubHost}" 'undefined hub host'

    # Install Role

    local -r serverConfigData=(
        '__PORT__' "${seleniumserverPort}"
        '__HUB_PORT__' "${seleniumserverHubPort}"
        '__HUB_HOST__' "${seleniumserverHubHost}"
    )

    installRole 'node' "${serverConfigData[@]}"
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
    install "${@}"
    installCleanUp

    displayOpenPorts
}

main "${@}"