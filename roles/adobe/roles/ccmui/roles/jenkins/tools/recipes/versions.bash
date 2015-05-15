#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local command="java -version &&
                   echo &&
                   node --version
                   echo &&
                   mvn -v"

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/jenkins.bash" \
        --command "${command}" \
        --machine-type 'master-slave'
}

main "${@}"