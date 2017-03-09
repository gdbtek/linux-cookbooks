#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${JENKINS_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${JENKINS_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    initializeFolder "${JENKINS_WORKSPACE_FOLDER}"
    addUser "${JENKINS_USER_NAME}" "${JENKINS_GROUP_NAME}" 'true' 'true' 'true'
    chown -R "${JENKINS_USER_NAME}:${JENKINS_GROUP_NAME}" "${JENKINS_WORKSPACE_FOLDER}"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/slave.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING SLAVE JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"