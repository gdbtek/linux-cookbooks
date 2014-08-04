#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash" || exit 1

    "${appPath}/../cookbooks/elastic-search/recipes/install.bash" || exit 1
}

main "${@}"