#!/bin/bash

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/../../../../cookbooks/mount-hd/recipes/install.bash" '/dev/sdb' '/opt/go-server' || exit 1

    "${appPath}/../../../essential.bash" || exit 1

    "${appPath}/../../../../cookbooks/aws-cli/recipes/install.bash" || exit 1
    "${appPath}/../../../../cookbooks/jdk/recipes/install.bash" || exit 1
    "${appPath}/../../../../cookbooks/node-js/recipes/install.bash" || exit 1
}

main "${@}"