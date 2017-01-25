#!/bin/bash -e

function installDependencies()
{
    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        installPackages 'libfontconfig'
    elif [[ "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        installPackages 'fontconfig'
    else
        fatal '\nFATAL : only support CentOS, RedHat or Ubuntu OS'
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${PHANTOM_JS_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${PHANTOM_JS_DOWNLOAD_URL}" "${PHANTOM_JS_INSTALL_FOLDER_PATH}"
    chown -R "$(whoami):$(whoami)" "${PHANTOM_JS_INSTALL_FOLDER_PATH}"
    ln -f -s "${PHANTOM_JS_INSTALL_FOLDER_PATH}/bin/phantomjs" '/usr/local/bin/phantomjs'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${PHANTOM_JS_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/phantom-js.sh.profile" '/etc/profile.d/phantom-js.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${PHANTOM_JS_INSTALL_FOLDER_PATH}/bin/phantomjs" --version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING PHANTOM-JS'

    installDependencies
    install
    installCleanUp
}

main "${@}"