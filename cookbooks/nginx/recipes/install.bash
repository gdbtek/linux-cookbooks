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

        createFileFromTemplate \
            "$(dirname "${BASH_SOURCE[0]}")/../templates/nginx.list.apt" \
            '/etc/apt/sources.list.d/nginx.list' \
            '__DISTRIBUTION_CODE_NAME__' "${DISTRIB_CODENAME}"

        curl -s -L 'http://nginx.org/keys/nginx_signing.key' --retry 12 --retry-delay 5 | apt-key add -
        apt-get update -m
    else
        local -r releaseFilePath='/etc/os-release'

        checkExistFile "${releaseFilePath}"

        source "${releaseFilePath}"

        # Set ID For Amazon Linux

        if [[ "${ID}" = 'amzn' ]]
        then
            ID="${NGINX_AMAZON_LINUX_ID}"
            VERSION_ID="${NGINX_AMAZON_LINUX_VERSION_ID}"
        fi

        # Generate Repo File

        createFileFromTemplate \
            "$(dirname "${BASH_SOURCE[0]}")/../templates/nginx.repo" \
            '/etc/yum.repos.d/nginx.repo' \
            '__PLATFORM_FAMILY__' "${ID}" \
            '__PLATFORM_VERSION__' "$(awk -F '.' '{ print $1 }' <<< "${VERSION_ID}")"
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
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING NGINX'

    checkRequireLinuxSystem
    checkRequireRootUser
    checkRequirePorts "${NGINX_PORT}"

    install
    installCleanUp
}

main "${@}"