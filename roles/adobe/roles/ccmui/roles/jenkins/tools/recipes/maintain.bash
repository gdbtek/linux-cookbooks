#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appPath}/upgrade.bash" "${attributeFile}"
    "${appPath}/clear-bash-history.bash" "${attributeFile}"
    "${appPath}/clear-npm-cache.bash" "${attributeFile}"
    "${appPath}/clear-workspace.bash" "${attributeFile}"
    "${appPath}/reset-logs.bash" "${attributeFile}"
    # "${appPath}/restart-machines.bash" "${attributeFile}"
}

main "${@}"