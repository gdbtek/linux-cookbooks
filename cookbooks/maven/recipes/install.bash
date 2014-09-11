#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${mavenJDKInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${mavenInstallFolder}"

    # Install

    unzipRemoteFile "${mavenDownloadURL}" "${mavenInstallFolder}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${mavenInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/maven.sh.profile" '/etc/profile.d/maven.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${mavenInstallFolder}/bin/mvn" -v)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MAVEN'

    installDependencies
    install
    installCleanUp
}

main "${@}"