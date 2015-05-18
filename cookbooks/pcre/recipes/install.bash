#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libbz2-dev' 'valgrind' 'zlib1g-dev'
}

function install()
{
    # Clean Up

    initializeFolder "${pcreInstallFolder:?}"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${pcreDownloadURL:?}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" "${pcreConfig[@]}"
    make
    make install
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${pcreInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/pcre.sh.profile" '/etc/profile.d/pcre.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${pcreInstallFolder}/bin/pcregrep" --version 2>&1)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PCRE'

    installDependencies
    install
    installCleanUp
}

main "${@}"