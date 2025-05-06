#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING CQLSH'

    checkRequireLinuxSystem
    checkRequireRootUser

    curl -fSL -o '/usr/bin/cortextool' "https://github.com/grafana/cortex-tools/releases/download/v0.11.3/cortextool_v0.11.3_Linux_x86_64"
    chmod 755 '/usr/bin/cortextool'
    cortexttool version
}

main "${@}"