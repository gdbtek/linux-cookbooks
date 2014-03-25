#!/bin/bash

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/../cookbooks/vim/recipes/install.bash" || exit 1
    "${appPath}/../cookbooks/ps1/recipes/install.bash" || exit 1
}

main
