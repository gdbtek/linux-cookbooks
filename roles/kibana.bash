#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash"

    "${appPath}/../cookbooks/nginx/recipes/install.bash"
    "${appPath}/../cookbooks/kibana/recipes/install.bash"
}

main "${@}"