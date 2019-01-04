#!/bin/bash -e

function main()
{
    local -r ps1HostName="${1}"
    local -r ps1Users="${2}"

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../libraries/util.bash"

    "${appFolderPath}/../cookbooks/essential/recipes/install.bash"

    "${appFolderPath}/../cookbooks/chrony/recipes/install.bash"
    "${appFolderPath}/../cookbooks/clean-up/recipes/install.bash"
    "${appFolderPath}/../cookbooks/jq/recipes/install.bash"
    "${appFolderPath}/../cookbooks/logrotate/recipes/install.bash"
    "${appFolderPath}/../cookbooks/ps1/recipes/install.bash" --host-name "${ps1HostName}" --users "${ps1Users}"
    "${appFolderPath}/../cookbooks/ssh/recipes/install.bash"
    "${appFolderPath}/../cookbooks/tweaks/recipes/install.bash"
    "${appFolderPath}/../cookbooks/ulimit/recipes/install.bash"
    "${appFolderPath}/../cookbooks/vim/recipes/install.bash"

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        "${appFolderPath}/../cookbooks/tmp-reaper/recipes/install.bash"
    else
        "${appFolderPath}/../cookbooks/tmp-watch/recipes/install.bash"
    fi

    postUpMessage
}

main "${@}"