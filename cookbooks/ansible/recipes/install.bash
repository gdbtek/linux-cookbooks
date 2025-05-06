#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    header 'INSTALLING ANSIBLE'

    checkRequireLinuxSystem
    checkRequireRootUser

    installPackages 'software-properties-common'
    add-apt-repository --yes --update ppa:ansible/ansible
    installPackages 'ansible'
    ansible --version
}

main "${@}"