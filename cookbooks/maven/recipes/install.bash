#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${MAVEN_JDK_INSTALL_FOLDER}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${MAVEN_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${MAVEN_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${MAVEN_DOWNLOAD_URL}" "${MAVEN_INSTALL_FOLDER}"

    # Config Lib

    chown -R "$(whoami):$(whoami)" "${MAVEN_INSTALL_FOLDER}"
    ln -f -s "${MAVEN_INSTALL_FOLDER}/bin/mvn" '/usr/local/bin/mvn'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${MAVEN_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/maven.sh.profile" '/etc/profile.d/maven.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${MAVEN_INSTALL_FOLDER}/bin/mvn" -v)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MAVEN'

    installDependencies
    install
    installCleanUp
}

main "${@}"