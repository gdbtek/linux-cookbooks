#!/bin/bash -e

function install()
{
    # Update Apt Source List

    local -r releaseFilePath='/etc/lsb-release'
    local -r aptSourceListFilePath='/etc/apt/sources.list'

    checkExistFile "${releaseFilePath}"

    source "${releaseFilePath}"

    echo >> "${aptSourceListFilePath}"
    echo "deb http://nginx.org/packages/mainline/ubuntu ${DISTRIB_CODENAME} nginx" >> "${aptSourceListFilePath}"
    echo "deb-src http://nginx.org/packages/mainline/ubuntu ${DISTRIB_CODENAME} nginx" >> "${aptSourceListFilePath}"

    curl -s -L 'http://nginx.org/keys/nginx_signing.key' --retry 12 --retry-delay 5 | apt-key add -

    apt-get update -m

    # Install

    installAptGetPackages 'nginx'

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    info "\n$(nginx -V 2>&1)"
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NGINX FROM BINARY'

    checkRequirePort "${NGINX_PORT}"

    install
    installCleanUp
}

main "${@}"