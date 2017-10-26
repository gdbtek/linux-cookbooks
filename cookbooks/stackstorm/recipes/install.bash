#!/bin/bash -e

function installDependencies()
{
    installPackage 'curl' 'curl'
    installPackage '' 'nss'
}

function install()
{
    umask '0022'

    # Install

    curl -sSL https://stackstorm.com/packages/install.sh |
    bash -s -- --user="${STACKSTORM_ADMIN_LOGIN}" --password="${STACKSTORM_ADMIN_PASSWORD}"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING STACKSTORM'

    installDependencies
    install
    installCleanUp
}

main "${@}"