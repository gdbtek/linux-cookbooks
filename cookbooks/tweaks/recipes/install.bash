#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appFolderPath}/disable-hugepage.bash"
    "${appFolderPath}/disable-tcp-timestamp.bash"
}

main "${@}"