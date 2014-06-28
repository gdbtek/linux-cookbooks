#!/bin/bash

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash" || exit 1

    "${appPath}/../../../../cookbooks/go-server/recipes/install-agent.bash" 'go.adobecc.com' || exit 1
    "${appPath}/config.bash" 'agent' || exit 1
    "${appPath}/../../../../cookbooks/ps1/recipes/install.bash" 'go' 'ubuntu' || exit 1
}

main "${@}"