#!/bin/bash -e

function main()
{
    # shellcheck source=/dev/null
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    runAptGetUpgrade
}

main "${@}"