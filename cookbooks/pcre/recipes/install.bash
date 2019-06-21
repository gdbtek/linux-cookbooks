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

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/pcre.sh.profile" '/etc/profile.d/pcre.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(pcregrep --version 2>&1)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING PCRE'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"