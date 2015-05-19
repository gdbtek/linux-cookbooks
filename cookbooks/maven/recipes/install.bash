#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${MAVEN_JDK_INSTALL_FOLDER}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${MAVEN_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${MAVEN_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${MAVEN_DOWNLOAD_URL}" "${MAVEN_INSTALL_FOLDER}"

    # Config Lib

    chown -R "$(whoami):$(whoami)" "${MAVEN_INSTALL_FOLDER}"
    ln -f -s "${MAVEN_INSTALL_FOLDER}/bin/mvn" '/usr/local/bin/mvn'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${MAVEN_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/default/maven.sh.profile" '/etc/profile.d/maven.sh' "${profileConfigData[@]}"

    # Display Version

    info "$("${MAVEN_INSTALL_FOLDER}/bin/mvn" -v)"
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