#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libbz2-dev' 'pkg-config' 'valgrind' 'zlib1g-dev'
}

function install()
{
    # Clean Up

    initializeFolder "${PCRE_INSTALL_FOLDER}"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${PCRE_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" "${PCRE_CONFIG[@]}"
    make
    make install
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${PCRE_INSTALL_FOLDER}")

    createFileFromTemplate "${appFolderPath}/../templates/pcre.sh.profile" '/etc/profile.d/pcre.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${PCRE_INSTALL_FOLDER}/bin/pcregrep" --version 2>&1)"
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PCRE'

    installDependencies
    install
    installCleanUp
}

main "${@}"