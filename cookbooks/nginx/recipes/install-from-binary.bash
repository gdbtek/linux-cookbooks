#!/bin/bash -e

function install()
{
    umask '0022'

    # Add Package Link

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        local -r releaseFilePath='/etc/lsb-release'

        checkExistFile "${releaseFilePath}"

        source "${releaseFilePath}"

        local -r configData=('__DISTRIBUTION_CODE_NAME__' "${DISTRIB_CODENAME}")

        createFileFromTemplate "${APP_FOLDER_PATH}/../templates/nginx.list.apt" '/etc/apt/sources.list.d/nginx.list' "${configData[@]}"
        curl -s -L 'http://nginx.org/keys/nginx_signing.key' --retry 12 --retry-delay 5 | apt-key add -
        apt-get update -m
    else
        local -r releaseFilePath='/etc/os-release'

        checkExistFile "${releaseFilePath}"

        source "${releaseFilePath}"

        # Set ID For Amazon Linux

        if [[ "${ID}" = 'amzn' ]]
        then
            ID="${AMAZON_LINUX_ID}"
            VERSION_ID="${AMAZON_LINUX_VERSION_ID}"
        fi

        # Generate Repo File

        local -r configData=(
            '__PLATFORM_FAMILY__' "${ID}"
            '__PLATFORM_VERSION__' "$(awk -F '.' '{ print $1 }' <<< "${VERSION_ID}")"
        )

        createFileFromTemplate "${APP_FOLDER_PATH}/../templates/nginx.repo" '/etc/yum.repos.d/nginx.repo' "${configData[@]}"
    fi

    # Install

    installPackages 'nginx'
    startService 'nginx'

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
    source "${APP_FOLDER_PATH}/../attributes/binary.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING NGINX FROM BINARY'

    checkRequirePorts "${NGINX_PORT}"

    install
    installCleanUp
}

main "${@}"