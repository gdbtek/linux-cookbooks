#!/bin/bash -e

function install()
{
    umask '0022'

    initializeFolder "${JDK_INSTALL_FOLDER_PATH}"
    curl -b 'oraclelicense=accept-securebackup-cookie' -C - -L "${JDK_DOWNLOAD_URL}" --retry 12 --retry-delay 5 |
    tar -C "${JDK_INSTALL_FOLDER_PATH}" -x -z --strip 1
    chown -R "$(whoami):$(whoami)" "${JDK_INSTALL_FOLDER_PATH}"

    symlinkListUsrBin \
        "${JDK_INSTALL_FOLDER_PATH}/bin/jar" \
        "${JDK_INSTALL_FOLDER_PATH}/bin/java" \
        "${JDK_INSTALL_FOLDER_PATH}/bin/javac"

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/jdk.sh.profile" \
        '/etc/profile.d/jdk.sh' \
        '__INSTALL_FOLDER_PATH__' \
        "${JDK_INSTALL_FOLDER_PATH}"

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