#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libssl-dev'
}

function install()
{
    # Clean Up

    initializeFolder "${wrkInstallFolder}"
    mkdir -p "${wrkInstallFolder}/bin"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    git clone "${wrkDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}" -maxdepth 1 -type f -perm -u+x -exec cp -f '{}' "${wrkInstallFolder}/bin" \;
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${wrkInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/wrk.sh.profile" '/etc/profile.d/wrk.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${wrkInstallFolder}/bin/wrk" --version)"
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING WRK'

    installDependencies
    install
    installCleanUp
}

main "${@}"