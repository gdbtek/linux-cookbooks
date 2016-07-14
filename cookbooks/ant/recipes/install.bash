#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${ANT_JDK_INSTALL_FOLDER}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${ANT_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${ANT_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${ANT_DOWNLOAD_URL}" "${ANT_INSTALL_FOLDER}"

    chown "$(whoami):$(whoami)" "${ANT_INSTALL_FOLDER}"
    ln -f -s "${ANT_INSTALL_FOLDER}/bin/ant" '/usr/local/bin/ant'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${ANT_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/ant.sh.profile" '/etc/profile.d/ant.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(ant -version)"
}

function main()
{
    local -r installFolder="${1}"

    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING ANT'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        ANT_INSTALL_FOLDER="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"