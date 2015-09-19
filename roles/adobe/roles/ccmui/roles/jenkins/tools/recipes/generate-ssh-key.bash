#!/bin/bash -e

function getCommands()
{
    local -r userName="${1}"

    echo "rm -f ~${userName}/.ssh/id_rsa ~${userName}/.ssh/id_rsa.pub &&
          ssh-keygen -q -t rsa -N '' -f ~${userName}/.ssh/id_rsa &&
          chmod 600 ~${userName}/.ssh/id_rsa ~${userName}/.ssh/id_rsa.pub &&
          cat ~${userName}/.ssh/id_rsa.pub"
}

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../../cookbooks/tomcat/attributes/default.bash"

    # Master

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "$(getCommands "${TOMCAT_USER_NAME}")" \
        --machine-type 'masters'

    # Slave

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "$(getCommands 'root')" \
        --machine-type 'slaves'
}

main "${@}"