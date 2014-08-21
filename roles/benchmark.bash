#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/../cookbooks/siege/recipes/install.bash"
    "${appPath}/../cookbooks/wrk/recipes/install.bash"
}

main "${@}"