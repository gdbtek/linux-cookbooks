#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command="java -version &&
                      echo &&
                      node --version
                      echo &&
                      mvn -v"

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/default.bash" \
        --command "${command}" \
        --machine-type 'masters-slaves'
}

main "${@}"