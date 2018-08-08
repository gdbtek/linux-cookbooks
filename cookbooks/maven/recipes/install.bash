#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${MAVEN_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${MAVEN_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${MAVEN_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${MAVEN_DOWNLOAD_URL}" "${MAVEN_INSTALL_FOLDER_PATH}"

    # Config Lib

    chown -R "$(whoami):$(whoami)" "${MAVEN_INSTALL_FOLDER_PATH}"
    ln -f -s "${MAVEN_INSTALL_FOLDER_PATH}/bin/mvn" '/usr/bin/mvn'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${MAVEN_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/maven.sh.profile" '/etc/profile.d/maven.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${MAVEN_INSTALL_FOLDER_PATH}/bin/mvn" -v)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING MAVEN'

    installDependencies
    install
    installCleanUp
}

main "${@}"