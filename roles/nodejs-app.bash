#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appFolderPath}/essential.bash"

    "${appFolderPath}/../cookbooks/node-js/recipes/install.bash"
    "${appFolderPath}/../cookbooks/redis/recipes/install.bash"
    "${appFolderPath}/../cookbooks/mongodb/recipes/install.bash"
    "${appFolderPath}/../cookbooks/nginx/recipes/install.bash"
}

main "${@}"