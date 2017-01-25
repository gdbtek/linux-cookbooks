#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${JDK_INSTALL_FOLDER_PATH}"

    # Install

    curl -b 'oraclelicense=accept-securebackup-cookie' -C - -L "${JDK_DOWNLOAD_URL}" --retry 12 --retry-delay 5 |
    tar -C "${JDK_INSTALL_FOLDER_PATH}" -x -z --strip 1

    # Config Lib

    chown -R "$(whoami):$(whoami)" "${JDK_INSTALL_FOLDER_PATH}"
    ln -f -s "${JDK_INSTALL_FOLDER_PATH}/bin/jar" '/usr/local/bin/jar'
    ln -f -s "${JDK_INSTALL_FOLDER_PATH}/bin/java" '/usr/local/bin/java'
    ln -f -s "${JDK_INSTALL_FOLDER_PATH}/bin/javac" '/usr/local/bin/javac'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${JDK_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/jdk.sh.profile" '/etc/profile.d/jdk.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(java -version 2>&1)"

    umask '0077'
}

function main()
{
    local -r installFolder="${1}"

    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING JDK'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        JDK_INSTALL_FOLDER_PATH="${installFolder}"
    fi

    # Install

    install
    installCleanUp
}

main "${@}"