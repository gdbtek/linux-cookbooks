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
    ln -f -s "${JDK_INSTALL_FOLDER_PATH}/bin/jar" '/usr/bin/jar'
    ln -f -s "${JDK_INSTALL_FOLDER_PATH}/bin/java" '/usr/bin/java'
    ln -f -s "${JDK_INSTALL_FOLDER_PATH}/bin/javac" '/usr/bin/javac'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${JDK_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/jdk.sh.profile" '/etc/profile.d/jdk.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(java -version 2>&1)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING JDK'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"