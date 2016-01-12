#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appFolderPath}/../cookbooks/siege/recipes/install.bash"
    "${appFolderPath}/../cookbooks/wrk/recipes/install.bash"
}

main "${@}"