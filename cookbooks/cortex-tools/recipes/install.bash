#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING CORTEX-TOOLS'

    checkRequireLinuxSystem
    checkRequireRootUser

    rm -f '/usr/bin/cortextool'
    curl -fSL -o '/usr/bin/cortextool' "${CORTEX_TOOLS_DOWNLOAD_URL}"
    chmod 755 '/usr/bin/cortextool'
    '/usr/bin/cortextool' 'version'
}

main "${@}"