#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${jenkinsJDKInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${jenkinsJDKInstallFolder}"
    fi
}

function install()
{
    initializeFolder "${jenkinsWorkspaceFolder}"
    chown -R "${jenkinsUserName}:${jenkinsGroupName}" "${jenkinsWorkspaceFolder}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/slave.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SLAVE JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"