#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    runUpgrade

    "$(dirname "${BASH_SOURCE[0]}")/clean-up.bash"
}

main "${@}"