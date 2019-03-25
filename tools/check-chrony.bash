#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    checkRequireLinuxSystem
    checkExistCommand 'chronyc'

    chronyc activity
    chronyc sources -v
    chronyc sourcestats -v
    chronyc tracking
}

main "${@}"