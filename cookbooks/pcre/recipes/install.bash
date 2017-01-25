#!/bin/bash -e

function installDependencies()
{
    installBuildEssential
    installPackages 'libbz2-dev' 'pkg-config' 'valgrind' 'zlib1g-dev'
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${PCRE_INSTALL_FOLDER_PATH}"

    # Install

    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${PCRE_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" "${PCRE_CONFIG[@]}"
    make
    make install
    rm -f -r "${tempFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${PCRE_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/pcre.sh.profile" '/etc/profile.d/pcre.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${PCRE_INSTALL_FOLDER_PATH}/bin/pcregrep" --version 2>&1)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING PCRE'

    installDependencies
    install
    installCleanUp
}

main "${@}"