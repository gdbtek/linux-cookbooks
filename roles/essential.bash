#!/bin/bash -e

function main()
{
    local -r ps1HostName="${1}"
    local -r ps1Users="${2}"

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appFolderPath}/../cookbooks/essential/recipes/install.bash"
    "${appFolderPath}/../cookbooks/jq/recipes/install.bash"
    "${appFolderPath}/../cookbooks/ntp/recipes/install.bash"
    "${appFolderPath}/../cookbooks/ps1/recipes/install.bash" --host-name "${ps1HostName}" --users "${ps1Users}"
    "${appFolderPath}/../cookbooks/ssh/recipes/install.bash"
    "${appFolderPath}/../cookbooks/vim/recipes/install.bash"

    "${appFolderPath}/../cookbooks/tmp-reaper/recipes/install.bash"
}

main "${@}"