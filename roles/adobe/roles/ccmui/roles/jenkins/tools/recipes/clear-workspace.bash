#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../../cookbooks/jenkins/attributes/slave.bash"

    local -r command="sudo rm -f -r ${JENKINS_WORKSPACE_FOLDER}/workspace"

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'slaves'
}

main "${@}"