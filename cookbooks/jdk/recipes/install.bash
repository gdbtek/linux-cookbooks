#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${installFolder}" '/usr/local/bin/java' '/usr/local/bin/javac'
    mkdir -p "${installFolder}"

    # Install

    unzipRemoteFile "${downloadURL}" "${installFolder}"

    # Config Lib

    chown -R "$(whoami)":"$(whoami)" "${installFolder}"
    ln -s "${installFolder}/bin/java" '/usr/local/bin/java'
    ln -s "${installFolder}/bin/javac" '/usr/local/bin/javac'

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${installFolder}")

    createFileFromTemplate "${appPath}/../files/profile/jdk.sh" '/etc/profile.d/jdk.sh' "${profileConfigData[@]}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING JDK'

    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"
