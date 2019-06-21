#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${MAVEN_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../jdk/recipes/install.bash" "${MAVEN_JDK_INSTALL_FOLDER_PATH}"
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

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/maven.sh.profile" '/etc/profile.d/maven.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(mvn -v)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING MAVEN'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"