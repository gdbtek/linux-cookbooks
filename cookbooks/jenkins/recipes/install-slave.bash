#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${JENKINS_JDK_INSTALL_FOLDER}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${JENKINS_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    initializeFolder "${JENKINS_WORKSPACE_FOLDER}"
    chown -R "${JENKINS_USER_NAME}:${JENKINS_GROUP_NAME}" "${JENKINS_WORKSPACE_FOLDER}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/slave.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SLAVE JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"