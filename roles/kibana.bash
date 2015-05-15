#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appPath}/essential.bash"

    "${appPath}/../cookbooks/nginx/recipes/install.bash"
    "${appPath}/../cookbooks/kibana/recipes/install.bash"
}

main "${@}"