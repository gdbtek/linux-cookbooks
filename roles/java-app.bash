#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash"

    "${appPath}/../cookbooks/jdk/recipes/install.bash"
}

main "${@}"