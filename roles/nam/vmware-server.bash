#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/../../cookbooks/ps1/recipes/install.bash" 'nam'
}

main "${@}"