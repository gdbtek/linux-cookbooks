#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${ANT_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${ANT_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    installDependencies
    installPortableBinary 'ANT' "${ANT_DOWNLOAD_URL}" "${ANT_INSTALL_FOLDER_PATH}" 'ant' '-version' 'true'
}

main "${@}"