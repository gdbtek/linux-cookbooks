#!/bin/bash -e

function main()
{
    local -r ps1HostName="${1}"
    local -r ps1Users="${2}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appPath}/../cookbooks/essential/recipes/install.bash"
    "${appPath}/../cookbooks/ntp/recipes/install.bash"
    "${appPath}/../cookbooks/ps1/recipes/install.bash" --host-name "${ps1HostName}" --users "${ps1Users}"
    "${appPath}/../cookbooks/ssh/recipes/install.bash"
    "${appPath}/../cookbooks/vim/recipes/install.bash"
}

main "${@}"