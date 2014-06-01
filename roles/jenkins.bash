#!/bin/bash

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash" || exit 1

    "${appPath}/../cookbooks/jdk/recipes/install.bash" || exit 1
    "${appPath}/../cookbooks/tomcat/recipes/install.bash" || exit 1
    "${appPath}/../cookbooks/jenkins/recipes/install.bash" || exit 1
    "${appPath}/../cookbooks/nginx/recipes/install.bash" || exit 1
}

main
