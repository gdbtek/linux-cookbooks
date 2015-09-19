#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../../../../../../cookbooks/tomcat/attributes/default.bash"

    local -r command="sudo rm -f \
        ~root/.bash_history \
        ~${TOMCAT_USER_NAME}/.bash_history
    "

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'masters-slaves'
}

main "${@}"