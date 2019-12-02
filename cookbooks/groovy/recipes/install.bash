#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../jdk/recipes/install.bash"
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${GROOVY_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${GROOVY_DOWNLOAD_URL}" "${GROOVY_INSTALL_FOLDER_PATH}"

    local -r unzipFolder="$(
        find "${GROOVY_INSTALL_FOLDER_PATH}" \
            -maxdepth 1 \
            -xtype d \
        2> '/dev/null' |
        tail -1
    )"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(wc -l <<< "${unzipFolder}")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    moveFolderContent "${unzipFolder}" "${GROOVY_INSTALL_FOLDER_PATH}"
    rm -f -r "${unzipFolder}"

    # Config Lib

    chown -R "$(whoami):$(whoami)" "${GROOVY_INSTALL_FOLDER_PATH}"
    symlinkListUsrBin "${GROOVY_INSTALL_FOLDER_PATH}/bin/groovy"

    # Config Profile

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/groovy.sh.profile" \
        '/etc/profile.d/groovy.sh' \
        '__INSTALL_FOLDER_PATH__' "${GROOVY_INSTALL_FOLDER_PATH}"

    # Display Version

    displayVersion "$(groovy --version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING GROOVY'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"