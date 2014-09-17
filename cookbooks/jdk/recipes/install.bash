#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${jdkInstallFolder}"
    rm -f '/usr/local/bin/jar' '/usr/local/bin/java' '/usr/local/bin/javac'

    # Install

    unzipRemoteFile "${jdkDownloadURL}" "${jdkInstallFolder}"

    # Config Lib

    chown -R "$(whoami):$(whoami)" "${jdkInstallFolder}"
    ln -s "${jdkInstallFolder}/bin/jar" '/usr/local/bin/jar'
    ln -s "${jdkInstallFolder}/bin/java" '/usr/local/bin/java'
    ln -s "${jdkInstallFolder}/bin/javac" '/usr/local/bin/javac'

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${jdkInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/jdk.sh.profile" '/etc/profile.d/jdk.sh' "${profileConfigData[@]}"

    # Display Version

    info "$(java -version 2>&1)"
}

function main()
{
    local installFolder="${1}"

    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING JDK'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        jdkInstallFolder="${installFolder}"
    fi

    # Install

    install
    installCleanUp
}

main "${@}"