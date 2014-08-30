#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash"

    "${appPath}/../cookbooks/ghost/recipes/install.bash"
    "${appPath}/../cookbooks/nginx/recipes/install.bash"
}

main "${@}"