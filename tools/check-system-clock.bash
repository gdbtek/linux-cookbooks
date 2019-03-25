#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    checkRequireLinuxSystem
    checkExistCommand 'chronyc'

    info '\nchronyc activity'
    chronyc activity

    info '\nchronyc sources -v'
    chronyc sources -v

    info '\nchronyc sourcestats -v'
    chronyc sourcestats -v

    info '\nchronyc tracking'
    chronyc tracking
}

main "${@}"