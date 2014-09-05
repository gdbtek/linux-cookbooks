#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appPath}/../../cookbooks/essential/recipes/install.bash"
    "${appPath}/../../cookbooks/ps1/recipes/install.bash" 'nam'
    "${appPath}/../../cookbooks/vim/recipes/install.bash"
}

main "${@}"