#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/docker/recipes/install.bash"

    docker image pull 'datastax/zdm-proxy:2.x'

    postUpMessage
}

main "${@}"