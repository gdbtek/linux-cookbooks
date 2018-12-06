#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appFolderPath}/disable-hugepage"
    "${appFolderPath}/disable-tcp-timestamp"
}

main "${@}"