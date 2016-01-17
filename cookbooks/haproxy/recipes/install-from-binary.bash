#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'software-properties-common'
}

function install()
{
    info '\nadd-apt-repository'
    add-apt-repository -y "ppa:vbernat/${HAPROXY_VERSION}"

    info '\napt-get update'
    apt-get update -m

    installAptGetPackages 'haproxy'

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    info "\n$(haproxy -vv 2>&1)"
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