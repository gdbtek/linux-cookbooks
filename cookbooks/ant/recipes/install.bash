#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${ANT_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../jdk/recipes/install.bash" "${ANT_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installDependencies
    installPortableBinary \
        'ANT' \
        "${ANT_DOWNLOAD_URL}" \
        "${ANT_INSTALL_FOLDER_PATH}" \
        'bin/ant' \
        '-version' \
        'true'
}

main "${@}"