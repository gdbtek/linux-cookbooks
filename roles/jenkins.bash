#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appFolderPath}/essential.bash"

    "${appFolderPath}/../cookbooks/jenkins/recipes/install-master.bash"
    "${appFolderPath}/../cookbooks/nginx/recipes/install.bash"
}

main "${@}"