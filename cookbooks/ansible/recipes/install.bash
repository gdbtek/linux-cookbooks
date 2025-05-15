#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING ANSIBLE'

    checkRequireLinuxSystem
    checkRequireRootUser

    if [[ "$(isAmazonLinuxDistributor)" = 'true' ]]
    then
        amazon-linux-extras install -y "${ANSIBLE_VERSION_AMAZON_LINUX}"
        ansible --version
    elif [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        installPackages 'software-properties-common'
        add-apt-repository --yes --update ppa:ansible/ansible
        installPackages 'ansible'
        ansible --version
    else
        fatal 'FATAL : only support Amazon-Linux, or Ubuntu OS'
    fi
}

main "${@}"