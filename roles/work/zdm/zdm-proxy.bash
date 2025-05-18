#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    apt-get install -y 'curl' 'software-properties-common' 'python3-pip' 'virtualenv' 'python3-setuptools'

    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/docker/recipes/install.bash"

    docker image pull 'datastax/zdm-proxy:2.x'

    postUpMessage
}

main "${@}"