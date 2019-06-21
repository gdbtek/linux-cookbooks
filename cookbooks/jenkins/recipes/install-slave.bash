#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${JENKINS_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../jdk/recipes/install.bash" "${JENKINS_JDK_INSTALL_FOLDER_PATH}"
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
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/slave.bash"

    header 'INSTALLING SLAVE JENKINS'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"