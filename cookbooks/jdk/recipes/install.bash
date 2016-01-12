#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${JDK_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${JDK_DOWNLOAD_URL}" "${JDK_INSTALL_FOLDER}"

    # Config Lib

    chown -R "$(whoami):$(whoami)" "${JDK_INSTALL_FOLDER}"
    ln -f -s "${JDK_INSTALL_FOLDER}/bin/jar" '/usr/local/bin/jar'
    ln -f -s "${JDK_INSTALL_FOLDER}/bin/java" '/usr/local/bin/java'
    ln -f -s "${JDK_INSTALL_FOLDER}/bin/javac" '/usr/local/bin/javac'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${JDK_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/jdk.sh.profile" '/etc/profile.d/jdk.sh' "${profileConfigData[@]}"

    # Display Version

    info "$(java -version 2>&1)"
}

function main()
{
    local -r installFolder="${1}"

    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING JDK'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        JDK_INSTALL_FOLDER="${installFolder}"
    fi

    # Install

    install
    installCleanUp
}

main "${@}"