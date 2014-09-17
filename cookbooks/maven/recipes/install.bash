#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${mavenJDKInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${mavenJDKInstallFolder}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${mavenInstallFolder}"
    rm -f '/usr/local/bin/mvn'

    # Install

    unzipRemoteFile "${mavenDownloadURL}" "${mavenInstallFolder}"

    # Config Lib

    chown -R "$(whoami):$(whoami)" "${mavenInstallFolder}"
    ln -s "${mavenInstallFolder}/bin/mvn" '/usr/local/bin/mvn'

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${mavenInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/maven.sh.profile" '/etc/profile.d/maven.sh' "${profileConfigData[@]}"

    # Display Version

    info "$("${mavenInstallFolder}/bin/mvn" -v)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MAVEN'

    installDependencies
    install
    installCleanUp
}

main "${@}"