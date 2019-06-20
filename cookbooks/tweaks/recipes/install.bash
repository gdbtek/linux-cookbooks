#!/bin/bash -e

function main()
{
    "$(dirname "${BASH_SOURCE[0]}")/disable-hugepage.bash"
    "$(dirname "${BASH_SOURCE[0]}")/disable-icmp-timestamp.bash"
    "$(dirname "${BASH_SOURCE[0]}")/disable-tcp-timestamp.bash"
}

main "${@}"