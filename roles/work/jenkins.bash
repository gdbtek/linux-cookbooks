#!/bin/bash -e

function configureJenkinsCI()
{
    umask '0022'

    createInitFileFromTemplate 'jenkins-ci' "$(dirname "${BASH_SOURCE[0]}")/templates"
    startService 'jenkins-ci'

    umask '0077'
}

function main()
{
    local -r ps1HostName="${1}"
    local -r ps1Users="${2}"

    source "$(dirname "${BASH_SOURCE[0]}")/../../libraries/util.bash"

    "$(dirname "${BASH_SOURCE[0]}")/../../cookbooks/clean-up/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../cookbooks/jq/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../cookbooks/logrotate/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../cookbooks/ps1/recipes/install.bash" --host-name "${ps1HostName}" --users "${ps1Users}"
    "$(dirname "${BASH_SOURCE[0]}")/../../cookbooks/vim/recipes/install.bash"

    configureJenkinsCI

    postUpMessage
}

main "${@}"