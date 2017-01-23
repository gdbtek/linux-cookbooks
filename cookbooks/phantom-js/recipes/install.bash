#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${PHANTOM_JS_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${PHANTOM_JS_DOWNLOAD_URL}" "${PHANTOM_JS_INSTALL_FOLDER}"
    chown -R "$(whoami):$(whoami)" "${PHANTOM_JS_INSTALL_FOLDER}"
    ln -f -s "${PHANTOM_JS_INSTALL_FOLDER}/bin/phantomjs" '/usr/local/bin/phantomjs'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${PHANTOM_JS_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/phantom-js.sh.profile" '/etc/profile.d/phantom-js.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${PHANTOM_JS_INSTALL_FOLDER}/bin/phantomjs" version)"

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

    install
    installCleanUp
}

main "${@}"