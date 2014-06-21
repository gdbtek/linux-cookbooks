#!/bin/bash

function install()
{
    curl -L 'https://www.opscode.com/chef/install.sh' | bash &&
    knife --version
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING CHEF'

    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"