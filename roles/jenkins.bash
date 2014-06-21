#!/bin/bash

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/java-web.bash" || exit 1

    "${appPath}/../cookbooks/jenkins/recipes/install.bash" || exit 1
}

main "${@}"