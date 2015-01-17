#!/bin/bash -e

function main()
{
    find "${BASH_SOURCE[0]}/.." -type f -name "*.bash" -exec shellcheck -s bash {} \;
}

main "${@}"