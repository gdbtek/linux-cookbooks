#!/bin/bash

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash" || exit 1

    "${appPath}/../../../../cookbooks/go-server/recipes/install-agent.bash" 'go.adobecc.com' || exit 1
    "${appPath}/../../../../cookbooks/ps1/recipes/install.bash" 'go' || exit 1
}

main "${@}"