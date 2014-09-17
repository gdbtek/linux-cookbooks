#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appPath}/essential.bash"

    "${appPath}/../cookbooks/jenkins/recipes/install-master.bash"
    "${appPath}/../cookbooks/nginx/recipes/install.bash"
}

main "${@}"