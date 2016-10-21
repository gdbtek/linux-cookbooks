#!/bin/bash -e

function install()
{
    umask '0022'

    # Update Apt Source List

    local -r releaseFilePath='/etc/lsb-release'

    checkExistFile "${releaseFilePath}"

    source "${releaseFilePath}"

    local -r configData=('__DISTRIBUTION_CODE_NAME__' "${DISTRIB_CODENAME}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/nginx.list.apt" '/etc/apt/sources.list.d/nginx.list' "${configData[@]}"
    curl -s -L 'http://nginx.org/keys/nginx_signing.key' --retry 12 --retry-delay 5 | apt-key add -
    apt-get update -m

    # Install

    installPackages 'nginx'

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    displayVersion "$(nginx -V 2>&1)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING NGINX FROM BINARY'

    checkRequirePorts "${NGINX_PORT}"

    install
    installCleanUp
}

main "${@}"