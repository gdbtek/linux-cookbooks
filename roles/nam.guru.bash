#!/bin/bash

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/essential.bash" || exit 1

    "${appPath}/../cookbooks/ufw/recipes/install.bash" || exit 1

    "${appPath}/../cookbooks/node-js/recipes/install.bash" || exit 1
    "${appPath}/../cookbooks/nginx/recipes/install.bash" || exit 1
    "${appPath}/../cookbooks/redis/recipes/install.bash" || exit 1
    "${appPath}/../cookbooks/mongodb/recipes/install.bash" || exit 1

    "${appPath}/../cookbooks/jdk/recipes/install.bash" || exit 1
    "${appPath}/../cookbooks/go/recipes/install.bash" || exit 1
}

main
