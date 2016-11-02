#!/bin/bash -e

function installDependencies()
{
    installBuildEssential
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${PARALLEL_INSTALL_FOLDER}"

    # Install

    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${PARALLEL_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${PARALLEL_INSTALL_FOLDER}"
    make
    make install
    ln -f -s "${PARALLEL_INSTALL_FOLDER}/bin/parallel" '/usr/local/bin/parallel'
    rm -f -r "${tempFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${PARALLEL_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/parallel.sh.profile" '/etc/profile.d/parallel.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(parallel --version)"

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

    header 'INSTALLING PARALLEL'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        PARALLEL_INSTALL_FOLDER="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"