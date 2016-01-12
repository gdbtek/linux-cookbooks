#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../../cookbooks/jenkins/attributes/slave.bash"

    local -r command="
        sudo rm -f -r ${JENKINS_WORKSPACE_FOLDER}/workspace &&
        sudo mkdir -p ${JENKINS_WORKSPACE_FOLDER}/workspace
    "

    "${appFolderPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'slaves'
}

main "${@}"