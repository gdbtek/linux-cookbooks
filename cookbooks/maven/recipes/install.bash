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

    initializeFolder "${MAVEN_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${MAVEN_DOWNLOAD_URL}" "${MAVEN_INSTALL_FOLDER_PATH}"
    chown -R "$(whoami):$(whoami)" "${MAVEN_INSTALL_FOLDER_PATH}"
    symlinkListUsrBin "${MAVEN_INSTALL_FOLDER_PATH}/bin/mvn"

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/maven.sh.profile" \
        '/etc/profile.d/maven.sh' \
        '__INSTALL_FOLDER_PATH__' "${MAVEN_INSTALL_FOLDER_PATH}"

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