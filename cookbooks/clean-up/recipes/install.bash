#!/bin/bash -e

function main()
{
    "$(dirname "${BASH_SOURCE[0]}")/install-delete-old-logs.bash"
}

main "${@}"