#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash"

    "${appPath}/../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../cookbooks/redis/recipes/install.bash"
    "${appPath}/../cookbooks/mongodb/recipes/install.bash"
    "${appPath}/../cookbooks/nginx/recipes/install.bash"
}

main "${@}"