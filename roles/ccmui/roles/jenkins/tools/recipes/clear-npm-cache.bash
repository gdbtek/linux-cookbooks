#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"
    local command='sudo rm -f -r \
        /tmp/* \
        /var/tmp/* \
        ~root/.cache \
        ~root/.node-gyp \
        ~root/.npm \
        ~root/.qws \
        ~root/tmp \
        ~tomcat/.cache \
        ~tomcat/.node-gyp \
        ~tomcat/.npm \
        ~tomcat/.qws \
        ~tomcat/tmp \
    '

    "${appPath}/../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/jenkins.bash" \
        --command "${command}" \
        --machine-type 'master-slave'
}

main "${@}"
