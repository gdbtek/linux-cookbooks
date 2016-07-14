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

    local -r tempFolder="$(getTemporaryFolder)"

    git clone "${WRK_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}" -maxdepth 1 -type f -perm -u+x -exec cp -f '{}' "${WRK_INSTALL_FOLDER}/bin" \;
    rm -f -r "${tempFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${WRK_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/wrk.sh.profile" '/etc/profile.d/wrk.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "\n$("${WRK_INSTALL_FOLDER}/bin/wrk" --version)"
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING WRK'

    installDependencies
    install
    installCleanUp
}

main "${@}"