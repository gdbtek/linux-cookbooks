#!/bin/bash -e

function installDependencies()
{
    installBuildEssential
    installPackage 'libssl-dev' 'openssl-devel'
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${WRK_INSTALL_FOLDER_PATH}"
    initializeFolder "${WRK_INSTALL_FOLDER_PATH}/bin"

    # Install

    local -r tempFolder="$(getTemporaryFolder)"

    git clone "${WRK_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}" -maxdepth 1 -xtype f -perm -u+x -exec cp -f '{}' "${WRK_INSTALL_FOLDER_PATH}/bin" \;
    rm -f -r "${tempFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${WRK_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/wrk.sh.profile" '/etc/profile.d/wrk.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${WRK_INSTALL_FOLDER_PATH}/bin/wrk" --version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING WRK'

    installDependencies
    install
    installCleanUp
}

main "${@}"