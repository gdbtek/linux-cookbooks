#!/bin/bash

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libssl-dev'
}

function install()
{
    # Clean Up

    rm -rf "${wrkInstallFolder}"
    mkdir -p "${wrkInstallFolder}/bin"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    git clone "${wrkDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}" -maxdepth 1 -type f -perm -u+x -exec cp -f {} "${wrkInstallFolder}/bin" \;
    rm -rf "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${wrkInstallFolder}")

    createFileFromTemplate "${appPath}/../files/profile/wrk.sh" '/etc/profile.d/wrk.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${wrkInstallFolder}/bin/wrk" --version)"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem

    header 'INSTALLING WRK'

    installDependencies
    install
    installCleanUp
}

main "${@}"