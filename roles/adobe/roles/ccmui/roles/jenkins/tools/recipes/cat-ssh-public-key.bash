#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../../cookbooks/tomcat/attributes/default.bash"

    # Master

    local -r masterCommand="cat ~${TOMCAT_USER_NAME}/.ssh/id_rsa.pub"

    "${appFolderPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${masterCommand}" \
        --machine-type 'masters'

    # Slave

    local -r slaveCommand='cat ~root/.ssh/id_rsa.pub'

    "${appFolderPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${slaveCommand}" \
        --machine-type 'slaves'
}

main "${@}"