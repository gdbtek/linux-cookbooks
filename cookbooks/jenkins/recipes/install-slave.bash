#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${JENKINS_JDK_INSTALL_FOLDER}" ]]
    then
        "${appFolderPath}/../../jdk/recipes/install.bash" "${JENKINS_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    initializeFolder "${JENKINS_WORKSPACE_FOLDER}"
    chown -R "${JENKINS_USER_NAME}:${JENKINS_GROUP_NAME}" "${JENKINS_WORKSPACE_FOLDER}"
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/slave.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SLAVE JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"