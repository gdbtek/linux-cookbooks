#!/bin/bash -e

function main()
{
    local -r ps1HostName="${1}"
    local -r ps1Users="${2}"

    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/essential/recipes/install.bash"

    "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/chrony/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/clean-up/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/jq/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/logrotate/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/ps1/recipes/install.bash" --host-name "${ps1HostName}" --users "${ps1Users}"
    "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/ssh/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/tweaks/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/ulimit/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/vim/recipes/install.bash"

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/tmp-reaper/recipes/install.bash"
    else
        "$(dirname "${BASH_SOURCE[0]}")/../cookbooks/tmp-watch/recipes/install.bash"
    fi

    postUpMessage
}

main "${@}"