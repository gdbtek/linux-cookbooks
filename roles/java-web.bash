#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appFolderPath}/essential.bash"

    "${appFolderPath}/../cookbooks/tomcat/recipes/install.bash"
    "${appFolderPath}/../cookbooks/nginx/recipes/install.bash"
}

main "${@}"