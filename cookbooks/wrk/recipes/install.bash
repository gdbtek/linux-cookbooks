#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libssl-dev'
}

function install()
{
    # Clean Up

    initializeFolder "${WRK_INSTALL_FOLDER}"
    mkdir -p "${WRK_INSTALL_FOLDER}/bin"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    git clone "${WRK_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}" -maxdepth 1 -type f -perm -u+x -exec cp -f '{}' "${WRK_INSTALL_FOLDER}/bin" \;
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${WRK_INSTALL_FOLDER}")

    createFileFromTemplate "${appFolderPath}/../templates/wrk.sh.profile" '/etc/profile.d/wrk.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${WRK_INSTALL_FOLDER}/bin/wrk" --version)"
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING WRK'

    installDependencies
    install
    installCleanUp
}

main "${@}"