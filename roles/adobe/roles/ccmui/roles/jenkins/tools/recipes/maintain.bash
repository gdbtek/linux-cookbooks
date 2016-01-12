#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appFolderPath}/upgrade.bash" "${attributeFile}"
    "${appFolderPath}/clear-bash-history.bash" "${attributeFile}"
    "${appFolderPath}/clear-workspace.bash" "${attributeFile}"
    "${appFolderPath}/clean-home.bash" "${attributeFile}"
    "${appFolderPath}/reset-logs.bash" "${attributeFile}"
    "${appFolderPath}/clear-npm-cache.bash" "${attributeFile}"
    # "${appFolderPath}/restart-machines.bash" "${attributeFile}"
}

main "${@}"