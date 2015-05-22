#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../../cookbooks/tomcat/attributes/default.bash"

    # Master

    local -r masterCommand="cat ~${TOMCAT_USER_NAME}/.ssh/id_rsa.pub"

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/default.bash" \
        --command "${masterCommand}" \
        --machine-type 'masters'

    # Slave

    local -r slaveCommand='cat ~root/.ssh/id_rsa.pub'

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/default.bash" \
        --command "${slaveCommand}" \
        --machine-type 'slaves'
}

main "${@}"