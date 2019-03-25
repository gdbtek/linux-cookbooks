#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    checkRequireLinuxSystem
    checkExistCommand 'chronyc'

    info 'chronyc activity'
    chronyc activity

    info 'chronyc sources -v'
    chronyc sources -v

    info 'chronyc sourcestats -v'
    chronyc sourcestats -v

    info 'chronyc tracking'
    chronyc tracking
}

main "${@}"