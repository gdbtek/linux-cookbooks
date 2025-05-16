#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    if [[ "$(isAmazonLinuxDistributor)" = 'true' ]]
    then
        installPackages 'libselinux-python'
    fi

    postUpMessage
}

main "${@}"