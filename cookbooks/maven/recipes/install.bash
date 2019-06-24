#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../jdk/recipes/install.bash"
    fi
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installDependencies
    installPortableBinary \
        'MAVEN' \
        "${MAVEN_DOWNLOAD_URL}" \
        "${MAVEN_INSTALL_FOLDER_PATH}" \
        'bin/maven' \
        '--version' \
        'true'
}

main "${@}"