#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/cqlsh/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/docker/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/zdm-util/recipes/install.bash"

    docker image pull 'datastax/zdm-ansible:2.x'

    postUpMessage
}

main "${@}"