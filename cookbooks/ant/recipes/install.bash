#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${ANT_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${ANT_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${ANT_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${ANT_DOWNLOAD_URL}" "${ANT_INSTALL_FOLDER_PATH}"

    chown "$(whoami):$(whoami)" "${ANT_INSTALL_FOLDER_PATH}"
    ln -f -s "${ANT_INSTALL_FOLDER_PATH}/bin/ant" '/usr/local/bin/ant'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${ANT_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/ant.sh.profile" '/etc/profile.d/ant.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(ant -version)"

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

    header 'INSTALLING ANT'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        ANT_INSTALL_FOLDER_PATH="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"