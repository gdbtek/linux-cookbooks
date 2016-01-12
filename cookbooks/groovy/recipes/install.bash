#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${GROOVY_JDK_INSTALL_FOLDER}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${GROOVY_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${GROOVY_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${GROOVY_DOWNLOAD_URL}" "${GROOVY_INSTALL_FOLDER}"

    local -r unzipFolder="$(find "${GROOVY_INSTALL_FOLDER}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(wc -l <<< "${unzipFolder}")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    moveFolderContent "${unzipFolder}" "${GROOVY_INSTALL_FOLDER}"
    rm -f -r "${unzipFolder}"

    # Config Lib

    chown -R "$(whoami):$(whoami)" "${GROOVY_INSTALL_FOLDER}"
    ln -f -s "${GROOVY_INSTALL_FOLDER}/bin/groovy" '/usr/local/bin/groovy'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${GROOVY_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/groovy.sh.profile" '/etc/profile.d/groovy.sh' "${profileConfigData[@]}"

    # Display Version

    info "$("${GROOVY_INSTALL_FOLDER}/bin/groovy" --version)"
}

function main()
{
    local -r installFolder="${1}"

    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GROOVY'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        GROOVY_INSTALL_FOLDER="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"