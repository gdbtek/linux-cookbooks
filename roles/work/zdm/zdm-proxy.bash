#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    installPackages 'libselinux-python'

    postUpMessage
}

main "${@}"