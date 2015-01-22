#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../cookbooks/tomcat/attributes/default.bash"

    local masterCommand="cat ~${tomcatUserName}/.ssh/id_rsa.pub"
    local slaveCommand='cat ~root/.ssh/id_rsa.pub'

    "${appPath}/../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/jenkins.bash" \
        --command "${masterCommand}" \
        --machine-type 'master'

    "${appPath}/../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/jenkins.bash" \
        --command "${slaveCommand}" \
        --machine-type 'slave'
}

main "${@}"