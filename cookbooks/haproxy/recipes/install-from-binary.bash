#!/bin/bash -e

function installDependencies()
{
    if [[ "${HAPROXY_VERSION}" != '1.4' ]]
    then
        installAptGetPackages 'software-properties-common'
    fi
}

function install()
{
    if [[ "${HAPROXY_VERSION}" != '1.4' ]]
    then
        info '\nadd-apt-repository'
        add-apt-repository -y "ppa:vbernat/haproxy-${HAPROXY_VERSION}"

        info '\napt-get update'
        apt-get update -m
    fi

    installAptGetPackages 'haproxy'

    # Enable Haproxy

    if [[ "${HAPROXY_VERSION}" = '1.4' ]]
    then
        echo 'ENABLED=1' > '/etc/default/haproxy'
    fi

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    displayVersion "\n$(haproxy -vv 2>&1)"
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/binary.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING HAPROXY FROM BINARY'

    installDependencies
    install
    installCleanUp
}

main "${@}"