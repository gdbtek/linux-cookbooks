#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'node')" = 'false' || "$(existCommand 'npm')" = 'false' || ! -d "${PM2_NODE_JS_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../node-js/recipes/install.bash" "${PM2_NODE_JS_VERSION}" "${PM2_NODE_JS_INSTALL_FOLDER_PATH}"
    fi
}

function resetOwnerAndSymlinkLocalBin()
{
    chown -R "$(whoami):$(whoami)" "${PM2_NODE_JS_INSTALL_FOLDER_PATH}"
    symlinkLocalBin "${PM2_NODE_JS_INSTALL_FOLDER_PATH}/bin"
}

function install()
{
    umask '0022'

    # Install

    npm install -g --prefix "${PM2_NODE_JS_INSTALL_FOLDER_PATH}" 'pm2@latest'

    # Reset Owner And Symlink Local Bin

    resetOwnerAndSymlinkLocalBin

    # Add User

    addUser "${PM2_USER_NAME}" "${PM2_GROUP_NAME}" 'true' 'true' 'true'

    local -r userHome="$(getUserHomeFolder "${PM2_USER_NAME}")"

    checkExistFolder "${userHome}"

    # Config Profile

    local -r profileConfigData=('__HOME_FOLDER__' "${userHome}/.pm2")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/pm2.sh.profile" '/etc/profile.d/pm2.sh' "${profileConfigData[@]}"

    # Config Log Rotate

    local -r logrotateConfigData=('__HOME_FOLDER__' "${userHome}/.pm2")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/pm2.logrotate" '/etc/logrotate.d/pm2' "${logrotateConfigData[@]}"

    # Clean Up

    local -r userHomeFolderPath="$(getCurrentUserHomeFolder)"

    rm -f -r "${userHomeFolderPath}/.cache" \
             "${userHomeFolderPath}/.npm"

    # Start

    export PM2_HOME="${userHome}/.pm2"
    pm2 startup 'linux' --hp "${userHome}/.pm2" --user "${PM2_USER_NAME}"
    pkill -f 'PM2'
    chown -R "${PM2_USER_NAME}:${PM2_GROUP_NAME}" "${userHome}/.pm2"
    service 'pm2-init.sh' start

    # Display Version

    displayVersion "Node Version : $(node --version)\nNPM Version  : $(npm --version)\nPM2 Version  : $(pm2 --version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING PM2'

    installDependencies
    install
    installCleanUp
}

main "${@}"