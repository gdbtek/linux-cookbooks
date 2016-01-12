#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appFolderPath}/essential.bash"

    "${appFolderPath}/../cookbooks/jdk/recipes/install.bash"
}

main "${@}"