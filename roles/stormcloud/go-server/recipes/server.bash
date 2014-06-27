#!/bin/bash

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash" || exit 1

    "${appPath}/../../../cookbooks/go-server/recipes/install-server.bash" || exit 1
    "${appPath}/config.bash" || exit 1
    "${appPath}/../../../cookbooks/ps1/recipes/install.bash" 'go' 'ubuntu' || exit 1
}

main "${@}"