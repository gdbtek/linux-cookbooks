#!/bin/bash

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash" || exit 1

    "${appPath}/../cookbooks/mysql/recipes/install.bash" || exit 1
}

main "${@}"