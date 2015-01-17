#!/bin/bash -e

function main()
{
    find "$(dirname "${BASH_SOURCE[0]}")/.." -type f -name "*.bash" -exec shellcheck -s bash {} \;
}

main "${@}"