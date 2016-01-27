#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appFolderPath}/essential.bash"

    "${appFolderPath}/../cookbooks/nginx/recipes/install-from-source.bash"
    "${appFolderPath}/../cookbooks/kibana/recipes/install.bash"
}

main "${@}"