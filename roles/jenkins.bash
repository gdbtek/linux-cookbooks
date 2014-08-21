#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/java-web.bash"

    "${appPath}/../cookbooks/jenkins/recipes/install.bash"
}

main "${@}"